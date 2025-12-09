import { verifyMessage } from "ethers";
import { SignJWT } from "jose";
// 生产环境使用环境变量
const JWT_SECRET = new TextEncoder().encode(process.env.JWT_SECRET);
// 生产环境使用 Redis
const challenges = new Map();

export async function authChallenge(address: string) {
  // 生成随机 Challenge
  const challenge = `请签名以登录 YeYing Wallet\n\n随机数: ${Math.random()
    .toString(36)
    .substring(7)}\n时间戳: ${Date.now()}`;
  // 保存 Challenge（5分钟过期）
  challenges.set(address.toLowerCase(), {
    challenge,
    timestamp: Date.now(),
  });
  return challenge;
}

export async function authVerify(address: string, signature: string) {
  const addressLower = address.toLowerCase();
  const challengeData = challenges.get(addressLower);
  if (!challengeData) {
    return "Challenge 不存在或已过期";
  }

  // 检查过期（5分钟）
  if (Date.now() - challengeData.timestamp > 5 * 60 * 1000) {
    challenges.delete(addressLower);
    return "Challenge 不存在或已过期";
  }

  // 验证签名
  const recoveredAddress = verifyMessage(challengeData.challenge, signature);
  if (recoveredAddress.toLowerCase() !== addressLower) {
    return "签名验证失败";
  }
  // 删除已使用的 Challenge
  challenges.delete(addressLower);
  // 生成 JWT Token
  return await generateToken(address.toLowerCase());
}

export async function generateToken(address: string) {
  const token = await new SignJWT({ address: address.toLowerCase() })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("24h")
    .sign(JWT_SECRET);

  return token;
}
