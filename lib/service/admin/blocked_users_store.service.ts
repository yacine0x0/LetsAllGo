import { promises as fs } from 'fs';
import path from 'path';

const DATA_DIR = path.join(process.cwd(), 'data');
const BLOCKED_USERS_FILE = path.join(DATA_DIR, 'blocked_users.json');

interface BlockedUsersData {
  userIds: string[];
}

async function ensureStoreFile(): Promise<void> {
  await fs.mkdir(DATA_DIR, { recursive: true });
  try {
    await fs.access(BLOCKED_USERS_FILE);
  } catch {
    const initial: BlockedUsersData = { userIds: [] };
    await fs.writeFile(BLOCKED_USERS_FILE, JSON.stringify(initial, null, 2), 'utf-8');
  }
}

async function readStore(): Promise<BlockedUsersData> {
  await ensureStoreFile();
  const raw = await fs.readFile(BLOCKED_USERS_FILE, 'utf-8');
  const parsed = JSON.parse(raw) as Partial<BlockedUsersData>;
  return {
    userIds: Array.isArray(parsed.userIds) ? parsed.userIds : [],
  };
}

async function writeStore(data: BlockedUsersData): Promise<void> {
  await ensureStoreFile();
  await fs.writeFile(BLOCKED_USERS_FILE, JSON.stringify(data, null, 2), 'utf-8');
}

export async function getBlockedUserIds(): Promise<Set<string>> {
  const store = await readStore();
  return new Set(store.userIds);
}

export async function isUserBlocked(userId: string): Promise<boolean> {
  const blockedIds = await getBlockedUserIds();
  return blockedIds.has(userId);
}

export async function setUserBlocked(userId: string, blocked: boolean): Promise<void> {
  const blockedIds = await getBlockedUserIds();
  if (blocked) {
    blockedIds.add(userId);
  } else {
    blockedIds.delete(userId);
  }
  await writeStore({ userIds: Array.from(blockedIds) });
}
