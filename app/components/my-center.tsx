import { useState, useEffect } from "react";

export function Centers() {
  // 模拟用户数据（实际中应从后端或状态管理中获取）
  const [userData, setUserData] = useState({
    phone: "138****1234",
    email: "user@example.com",
    walletName: "My Wallet",
    walletAddress: "0x1234...abcd",
  });

  const [storageUsage, setStorageUsage] = useState({
    used: 12.5, // GB
    total: 50, // GB
  });

  const [apiUsage, setApiUsage] = useState({
    totalCost: 23.5, // 元
    totalTokens: 125000,
    thisMonthCost: 8.2,
    thisMonthTokens: 42000,
  });

  // 可选：组件挂载时加载真实数据
  useEffect(() => {
    // 模拟 API 调用
    // fetchUserData().then(data => setUserData(data));
    // fetchUsageData().then(data => { setStorageUsage(...); setApiUsage(...); });
  }, []);

  // 计算存储使用百分比
  const storagePercent = (
    (storageUsage.used / storageUsage.total) *
    100
  ).toFixed(1);

  return (
    <div
      style={{
        padding: "1.25rem", // 20px → 1.25rem（更响应式）
        maxWidth: "min(800px, 95vw)", // 关键：限制最大宽度，但小屏时用 95% 视口宽
        margin: "0 auto",
        fontFamily: "Arial, sans-serif",
        boxSizing: "border-box", // 确保 padding 不影响总宽
      }}
    >
      <h1 style={{ textAlign: "center", marginBottom: "1.875rem" }}>
        个人中心
      </h1>

      {/* 1. 存储使用情况 */}
      <div style={sectionStyle}>
        <h2>存储使用情况</h2>
        <p>
          已使用：{storageUsage.used} GB / {storageUsage.total} GB
        </p>
        <div style={progressBarContainer}>
          <div style={{ ...progressBar, width: `${storagePercent}%` }}></div>
        </div>
        <p>使用率：{storagePercent}%</p>
      </div>

      {/* 2. 大模型 API 使用明细 */}
      <div style={sectionStyle}>
        <h2>大模型 API 使用情况</h2>
        <ul style={listStyle}>
          <li>本月消费：¥{apiUsage.thisMonthCost}</li>
          <li>本月 Tokens：{apiUsage.thisMonthTokens.toLocaleString()}</li>
          <li>累计消费：¥{apiUsage.totalCost}</li>
          <li>累计 Tokens：{apiUsage.totalTokens.toLocaleString()}</li>
        </ul>
      </div>

      {/* 3. 扩容与充值入口 */}
      <div style={sectionStyle}>
        <h2>账户服务</h2>
        <div
          style={{
            display: "flex",
            flexWrap: "wrap", // 允许按钮在窄屏换行
            gap: "1rem", // 使用 rem 更响应
            marginTop: "0.625rem",
          }}
        >
          <button style={buttonStyle}>扩容存储</button>
          <button style={buttonStyle}>充值余额</button>
        </div>
      </div>

      {/* 4. 手机号与邮箱 */}
      <div style={sectionStyle}>
        <h2>联系方式</h2>
        <p>手机号：{userData.phone}</p>
        <p>邮箱：{userData.email}</p>
      </div>

      {/* 5. 钱包信息 */}
      <div style={sectionStyle}>
        <h2>钱包信息</h2>
        <p>钱包名称：{userData.walletName}</p>
        <p style={{ wordBreak: "break-all" }}>
          钱包地址：{userData.walletAddress}
        </p>
      </div>
    </div>
  );
}

const sectionStyle = {
  marginBottom: "1.5rem",
  padding: "1rem",
  border: "1px solid #ddd",
  borderRadius: "0.5rem",
  backgroundColor: "#fafafa",
  boxSizing: "border-box",
};

const listStyle = {
  listStyleType: "none",
  paddingLeft: 0,
  margin: 0,
};

const progressBarContainer = {
  height: "0.75rem", // 12px → 0.75rem
  backgroundColor: "#e0e0e0",
  borderRadius: "0.375rem",
  overflow: "hidden",
  marginTop: "0.5rem",
  marginBottom: "0.5rem",
};

const progressBar = {
  height: "100%",
  backgroundColor: "#4caf50",
  transition: "width 0.3s ease",
  minWidth: "2px", // 防止极低使用率时看不见
};

const buttonStyle = {
  padding: "0.5rem 1rem", // 8px 16px → 相对单位
  backgroundColor: "#1976d2",
  color: "white",
  border: "none",
  borderRadius: "0.25rem",
  cursor: "pointer",
  fontSize: "1rem",
  whiteSpace: "nowrap", // 防止按钮文字换行
};
