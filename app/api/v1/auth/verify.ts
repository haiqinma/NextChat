// pages/api/v1/auth/verify.ts
import { createProxyMiddleware } from "http-proxy-middleware";
import type { NextApiRequest, NextApiResponse } from "next";

const TARGET_URL = process.env.BACKEND_URL || "http://localhost:8080";

const proxy = createProxyMiddleware({
  target: TARGET_URL,
  changeOrigin: true,
  pathRewrite: {
    "^/api/v1/auth/verify": "/api/v1/auth/verify",
  },
});

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

export const config = {
  api: {
    bodyParser: false,
  },
};
