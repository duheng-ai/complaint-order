// ===================== OpenClaw 标准技能（已修复）=====================
const axios = require('axios');

// ========================
// ⚙️ 配置区域
// ========================
const CONFIG = {
  LOGIN: {
    phone: "17681828467",
    password: "DH123456",
    system: "operation",
    type: "password"
  },
  API: {
    baseUrl: "https://api.lianok.com",
    loginEndpoint: "/common/v1/user/login",
    queryEndpoint: "/operation/v1/flow/selectByPage"
  },
  initialToken: "ca83f4d3812f42688d6052bc4fba5d35"
};

// ===================== OpenClaw 标准导出（核心修复）=====================
module.exports = {
  // 元数据（与 SKILL.md 对齐）
  meta: {
    id: "complaint-order",
    name: "通道投诉订单查询",
    description: "自动解析投诉信息，查询订单并格式化输出（401 自动刷新 token）",
    version: "2.3.1",
    author: "duheng"
  },

  // ========================
  // OpenClaw 唯一执行入口（标准格式）
  // ========================
  async execute(context) {
    try {
      // 标准上下文获取（OpenClaw 规范）
      const userInput = context.input || '';
      let accessToken = CONFIG.initialToken;
      const API_URL = `${CONFIG.API.baseUrl}${CONFIG.API.queryEndpoint}`;

      // ========================
      // 1. 请求封装（401 自动刷新）
      // ========================
      const request = async (url, data) => {
        try {
          return await axios({
            method: 'post',
            url: url,
            data: data,
            headers: {
              'accessToken': accessToken,
              'Content-Type': 'application/json',
              'client': 'WEB'
            }
          });
        } catch (err) {
          if (err.response?.status === 401) {
            const newToken = await this.getNewToken();
            if (!newToken) throw new Error('登录已失效，自动刷新 token 失败');
            accessToken = newToken;
            // 重试
            return axios({
              method: 'post',
              url: url,
              data: data,
              headers: {
                'accessToken': accessToken,
                'Content-Type': 'application/json',
                'client': 'WEB'
              }
            });
          }
          throw err;
        }
      };

      // ========================
      // 2. 获取新 Token
      // ========================
      this.getNewToken = async () => {
        try {
          const res = await axios.post(`${CONFIG.API.baseUrl}${CONFIG.API.loginEndpoint}`, CONFIG.LOGIN);
          return res.data?.data?.accessToken || null;
        } catch (err) {
          console.error("Token 刷新失败:", err.message);
          return null;
        }
      };

      // ========================
      // 3. 订单日期解析
      // ========================
      this.getOrderDate = (orderNo) => {
        if (!orderNo) return null;
        // 1026 规则
        if (/^1026\d{3}/.test(orderNo)) {
          const year = 2026;
          const dayOfYear = parseInt(orderNo.slice(4, 7), 10);
          const date = new Date(year, 0, 1);
          date.setDate(dayOfYear);
          const ymd = date.getFullYear() + '-' + 
                      String(date.getMonth() + 1).padStart(2, '0') + '-' + 
                      String(date.getDate()).padStart(2, '0');
          return { queryBeginPayTime: `${ymd} 00:00:00`, queryEndPayTime: `${ymd} 23:59:59` };
        }
        // 42000 规则
        if (/^42000/.test(orderNo) && orderNo.length >= 18) {
          const dateStr = orderNo.slice(10, 18);
          if (/^\d{8}$/.test(dateStr)) {
            const y = dateStr.slice(0,4), m = dateStr.slice(4,6), d = dateStr.slice(6,8);
            return { queryBeginPayTime: `${y}-${m}-${d} 00:00:00`, queryEndPayTime: `${y}-${m}-${d} 23:59:59` };
          }
        }
        // 20xxxx 规则
        if (/^20\d{2}/.test(orderNo)) {
          const dateStr = orderNo.slice(0,8);
          if (/^\d{8}$/.test(dateStr)) {
            const y = dateStr.slice(0,4), m = dateStr.slice(4,6), d = dateStr.slice(6,8);
            return { queryBeginPayTime: `${y}-${m}-${d} 00:00:00`, queryEndPayTime: `${y}-${m}-${d} 23:59:59` };
          }
        }
        return null;
      };

      // ========================
      // 4. 解析投诉消息
      // ========================
      this.parseMsg = (text) => {
        const msgList = text.trim().split(/\n\s*\n/);
        const result = [];
        for (const msg of msgList) {
          if (!msg.trim()) continue;
          const lines = msg.split('\n');
          let telephone = '无', complaintContent = '无', OrderNo = '无';
          for (const line of lines) {
            const trimmed = line.trim();
            const phoneMatch = trimmed.match(/用户联系方式\s*[:：]\s*(\d+)/);
            if (phoneMatch) telephone = phoneMatch[1];
            const complaintMatch = trimmed.match(/(?:用户)?投诉内容\s*[:：]\s*(.+)/);
            if (complaintMatch) complaintContent = complaintMatch[1].trim();
            const orderMatch = trimmed.match(/订单号\s*[:：]\s*(\d+)/);
            if (orderMatch) OrderNo = orderMatch[1];
          }
          result.push({ telephone, complaintContent, OrderNo });
        }
        return result;
      };

      // ========================
      // 5. 格式化输出
      // ========================
      this.formatOutput = (data, telephone, orderNo, complaint) => {
        const { list = [] } = data || {};
        let orderLabel = "官方订单号";
        if (orderNo.startsWith("1026")) orderLabel = "火脸订单号";
        else if (orderNo.startsWith("42000") || /^20\d{2}/.test(orderNo)) orderLabel = "官方订单号";

        if (!list.length) {
          return `所属服务商：无
消费者联系方式：${telephone}
${orderLabel}：${orderNo}
查询结果：未查询到订单信息
投诉内容：${complaint}`;
        }

        const outputs = [];
        list.forEach(order => {
          outputs.push(
            `所属服务商：${order.agentName || '无'}\n` +
            `商户 ID：${order.shopNo || '无'} 商户名称：${order.shopShortName || '无'} 存在${order.payChannelName || '无'}通道投诉\n` +
            `消费者联系方式：${telephone}\n` +
            `${orderLabel}：${orderNo}\n` +
            `订单金额：¥${order.totalAmount || '无'}\n` +
            `支付时间：${order.payTime || '无'}\n` +
            `投诉内容：${complaint}`
          );
        });
        return outputs.join('\r\n\r\n');
      };

      // ========================
      // 6. 查询订单
      // ========================
      this.queryOrder = async (orderNo) => {
        const timeRange = this.getOrderDate(orderNo);
        if (!timeRange) return { list: [] };
        let list = [];
        try {
          // 查 orderNo
          const res1 = await request(API_URL, { currentPage:1, pageSize:100, ...timeRange, orderNo });
          if (res1.data.code === 0 && Array.isArray(res1.data.data)) list = res1.data.data;
          // 查 topChannelOrderNo
          if (list.length === 0) {
            const res2 = await request(API_URL, { currentPage:1, pageSize:100, ...timeRange, topChannelOrderNo: orderNo });
            if (res2.data.code === 0 && Array.isArray(res2.data.data)) list = res2.data.data;
          }
          return { list };
        } catch (err) {
          console.error("查询失败:", err.message);
          return { list: [] };
        }
      };

      // ========================
      // 主逻辑执行
      // ========================
      const parseList = this.parseMsg(userInput);
      if (!parseList.length) return { text: '未解析到有效投诉信息' };

      const outputArr = [];
      for (const item of parseList) {
        const { telephone, complaintContent, OrderNo } = item;
        if (OrderNo === '无') {
          outputArr.push(`订单号为空，跳过处理 | 联系方式：${telephone}`);
          continue;
        }
        const orderData = await this.queryOrder(OrderNo);
        outputArr.push(this.formatOutput(orderData, telephone, OrderNo, complaintContent));
      }

      // 标准返回（OpenClaw 必须返回 { text }）
      return { text: outputArr.join('\n') };

    } catch (err) {
      return { text: `❌ 查询异常：${err.message}` };
    }
  }
};