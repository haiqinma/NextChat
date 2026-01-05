# 本地启动

    cp .env.template .env.local && npm install && npm run dev


# 测试机器启动

## 先启动 nextjs
    
    cd /home/ubuntu/code/NextChat/NextChat
    git pull
    npm install && npm run build
    PORT=3000 nohup npm start > nextjs.log 2>&1 &

## 然后启动 nginx

    cd /home/ubuntu/code/NextChat && bash startService.sh