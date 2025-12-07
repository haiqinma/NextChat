import { toast } from "sonner";
export const notifyError = (msg: string) => {
  // ElNotification({
  //     title: '❌错误',
  //     message: `❌${msg}`,
  //     type: 'error',
  //     position: 'top-right',
  //     duration: 3000,
  //     dangerouslyUseHTMLString: true
  // })
  console.log(`toast.error`);
  toast.error("❌错误", {
    description: `❌${msg}`,
    duration: 3000,
  });
};

export const notifyInfo = (msg: string) => {
  // ElNotification({
  //     title: '🎉消息',
  //     message: `🧶${msg}`,
  //     type: 'info',
  //     position: 'top-right',
  //     duration: 3000,
  //     dangerouslyUseHTMLString: true
  // })
  console.log(`toast.info`);
  toast.info("🎉消息", {
    description: `🧶${msg}`,
  });
};

export const notifySuccess = (msg: string) => {
  // ElNotification({
  //     title: '✅成功',
  //     message: `🌿${msg}`,
  //     type: 'success',
  //     position: 'top-right',
  //     duration: 3000,
  //     dangerouslyUseHTMLString: true
  // })
  console.log(`toast.success`);
  toast.success("✅成功", {
    description: `🌿${msg}`,
  });
};
