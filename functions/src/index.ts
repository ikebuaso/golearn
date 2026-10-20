import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import { Webhook } from "svix";

initializeApp();

const clerkWebhookSecret = defineSecret("CLERK_WEBHOOK_SECRET");
const clerkSecretKey = defineSecret("CLERK_SECRET_KEY");
const firestore = getFirestore();
const roles = ["student", "instructor", "admin"] as const;

type UserRole = (typeof roles)[number];

function isUserRole(value: unknown): value is UserRole {
  return roles.some((role) => role === value);
}

interface ClerkWebhookUser {
  id: string;
  first_name?: string | null;
  last_name?: string | null;
  primary_email_address_id?: string | null;
  email_addresses?: Array<{
    id: string;
    email_address: string;
  }>;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseUser(value: unknown): ClerkWebhookUser | null {
  if (!isRecord(value) || typeof value.id !== "string") return null;

  const emailAddresses = Array.isArray(value.email_addresses)
    ? value.email_addresses.flatMap((email) =>
        isRecord(email) &&
        typeof email.id === "string" &&
        typeof email.email_address === "string"
          ? [{ id: email.id, email_address: email.email_address }]
          : [],
      )
    : [];

  return {
    id: value.id,
    first_name: typeof value.first_name === "string" ? value.first_name : null,
    last_name: typeof value.last_name === "string" ? value.last_name : null,
    primary_email_address_id:
      typeof value.primary_email_address_id === "string"
        ? value.primary_email_address_id
        : null,
    email_addresses: emailAddresses,
  };
}

function getEmail(user: ClerkWebhookUser): string {
  const emails = user.email_addresses ?? [];
  const primary = emails.find(
    (email) => email.id === user.primary_email_address_id,
  );
  return primary?.email_address ?? emails[0]?.email_address ?? "";
}

function getRole(value: unknown): UserRole {
  return isUserRole(value) ? value : "student";
}

async function syncPublicMetadata(userId: string): Promise<{
  role: UserRole;
  approved: boolean;
}> {
  const headers = {
    Authorization: `Bearer ${clerkSecretKey.value()}`,
    "Content-Type": "application/json",
  };
  const userResponse = await fetch(
    `https://api.clerk.com/v1/users/${encodeURIComponent(userId)}`,
    { headers },
  );
  if (!userResponse.ok) {
    throw new Error(`Clerk user lookup failed (${userResponse.status}).`);
  }

  const userPayload: unknown = await userResponse.json();
  const metadata = isRecord(userPayload) && isRecord(userPayload.public_metadata)
    ? userPayload.public_metadata
    : {};
  const role = getRole(metadata.role);
  const approved = metadata.approved === true;
  const needsMetadataUpdate =
    !isUserRole(metadata.role) ||
    typeof metadata.approved !== "boolean";

  if (needsMetadataUpdate) {
    const updateResponse = await fetch(
      `https://api.clerk.com/v1/users/${encodeURIComponent(userId)}/metadata`,
      {
        method: "PATCH",
        headers,
        body: JSON.stringify({
          public_metadata: {
            role,
            approved:
              typeof metadata.approved === "boolean"
                ? metadata.approved
                : false,
          },
        }),
      },
    );
    if (!updateResponse.ok) {
      throw new Error(`Clerk metadata update failed (${updateResponse.status}).`);
    }
  }

  return { role, approved };
}

export const clerkUserWebhook = onRequest(
  {
    secrets: [clerkWebhookSecret, clerkSecretKey],
    timeoutSeconds: 30,
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.set("Allow", "POST").status(405).send("Method not allowed.");
      return;
    }

    let payload: unknown;
    try {
      payload = new Webhook(clerkWebhookSecret.value()).verify(
        request.rawBody,
        {
          "svix-id": request.header("svix-id") ?? "",
          "svix-timestamp": request.header("svix-timestamp") ?? "",
          "svix-signature": request.header("svix-signature") ?? "",
        },
      );
    } catch {
      response.status(400).send("Invalid webhook signature.");
      return;
    }

    if (!isRecord(payload) || typeof payload.type !== "string") {
      response.status(400).send("Invalid webhook payload.");
      return;
    }

    if (payload.type === "user.deleted") {
      const deletedUser = parseUser(payload.data);
      if (!deletedUser) {
        response.status(400).send("Invalid deleted-user payload.");
        return;
      }
      await firestore.collection("users").doc(deletedUser.id).delete();
      response.status(200).send("User profile deleted.");
      return;
    }

    if (payload.type !== "user.created" && payload.type !== "user.updated") {
      response.status(200).send("Event ignored.");
      return;
    }

    const user = parseUser(payload.data);
    if (!user) {
      response.status(400).send("Invalid user payload.");
      return;
    }

    const { role, approved } = await syncPublicMetadata(user.id);
    const name = [user.first_name, user.last_name]
      .filter((part): part is string => typeof part === "string" && part !== "")
      .join(" ");
    const profile = firestore.collection("users").doc(user.id);
    await firestore.runTransaction(async (transaction) => {
      const existingProfile = await transaction.get(profile);
      transaction.set(
        profile,
        {
          name,
          email: getEmail(user),
          role,
          approved,
          ...(!existingProfile.exists && {
            createdAt: FieldValue.serverTimestamp(),
          }),
        },
        { merge: true },
      );
    });

    response.status(200).send("User profile synchronized.");
  },
);
