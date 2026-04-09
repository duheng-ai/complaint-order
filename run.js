#!/usr/bin/env node

/**
 * complaint-order - 独立运行入口
 * 用于本地测试技能逻辑
 * 
 * 用法：node run.js "用户联系方式：13800138000 订单号：123456"
 */

const skill = require('./index.js');

async function main() {
  const mockContext = {
    session: { id: 'test-session' },
    userMessage: process.argv.slice(2).join(' ') || '测试消息'
  };

  console.log('===== 输入消息 =====');
  console.log(mockContext.userMessage);
  console.log('\n===== 执行结果 =====');

  try {
    const result = await skill.execute(mockContext);
    console.log(result);
  } catch (err) {
    console.error('执行失败:', err.message);
    process.exit(1);
  }
}

main();
