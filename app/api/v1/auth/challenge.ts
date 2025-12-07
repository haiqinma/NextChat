// pages/api/v1/auth/challenge.ts
import { createProxyMiddleware } from "http-proxy-middleware";
import type { NextApiRequest, NextApiResponse } from "next";

// 真实后端地址（从环境变量读取更安全）
const TARGET_URL = process.env.BACKEND_URL || "http://localhost:8080";

const proxy = createProxyMiddleware({
  target: TARGET_URL,
  changeOrigin: true,
  pathRewrite: {
    "^/api/v1/auth/challenge": "/api/v1/auth/challenge", // 路径不变，直接透传
  },
});
console.log(`钱包接口url TARGET_URL=${TARGET_URL}`);
export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  return new Promise<void>((resolve) => {
    proxy(req, res, (err) => {
      if (err) {
        console.error("Proxy error:", err);
        res.status(500).json({ error: "Proxy failed" });
      }
      resolve();
    });
  });
}

// 关键：禁用 body 解析，让 proxy 处理原始流
export const config = {
  api: {
    bodyParser: false,
  },
};
