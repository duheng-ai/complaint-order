# 更新日志 - 通道投诉订单查询技能 (complaint-order)

***

## v2.3.1 (2026-04-09)

### 📦 版本信息

| 项目       | 值                                     |
| -------- | ------------------------------------- |
| **发布日期** | 2026-04-09                            |
| **上一版本** | v2.3.0 (2026-04-03)                   |
| **变更类型** | 文档更新                                  |
| **技能位置** | `~/.openclaw/skills/complaint-order/` |

### 📝 更新内容

#### 核心代码重构（2026-04-09）

**1. 技能元信息标准化**

- 技能 ID：`channelcomplaint` → `complaint-order`（与目录名保持一致）
- 移除 `triggers` 配置（OpenClaw 不再需要）
- `meta` 移至 `module.exports` 内部，符合标准技能规范

**2. 执行入口重构**

- 上下文获取：`context.userMessage` → `context.input`（OpenClaw 标准字段）
- 所有辅助方法改为实例方法：`this.getNewToken()`、`this.getOrderDate()` 等
- 方法定义移至 `execute()` 函数内部，避免模块级导出

**3. 代码结构优化**

- 移除独立的方法导出，全部封装在 `execute()` 内
- 简化注释，移除冗余说明
- 统一变量命名：`userMessage` → `userInput`
- `queryOrder` 方法返回值简化：移除 `source` 字段

**4. 方法组织调整**

| 方法               | 旧版    | 新版                         |
| ---------------- | ----- | -------------------------- |
| `getNewToken()`  | 模块级方法 | `this.getNewToken()` 实例方法  |
| `getOrderDate()` | 模块级方法 | `this.getOrderDate()` 实例方法 |
| `parseMsg()`     | 模块级方法 | `this.parseMsg()` 实例方法     |
| `formatOutput()` | 模块级方法 | `this.formatOutput()` 实例方法 |
| `queryOrder()`   | 模块级方法 | `this.queryOrder()` 实例方法   |

**5. 请求封装改进**

- 401 自动刷新逻辑保持不变
- 重试机制保持不变
- Token 管理逻辑保持不变

**6. 功能保持不变**

- ✅ 3 种订单号格式解析（1026/42000/20 开头）
- ✅ 401 自动刷新 token
- ✅ 批量处理多条投诉
- ✅ 格式化输出（服务商、商户、订单详情）

***

#### 今日文档更新

- ✅ 更新 README.md - 添加 GitHub 仓库链接
- ✅ 更新 CHANGELOG.md - 记录版本历史
- ✅ 初始化 Git 仓库（本地）

***

## v2.3.0 (2026-04-03)

### 📦 版本信息

| 项目       | 值                                     |
| -------- | ------------------------------------- |
| **发布日期** | 2026-04-03                            |
| **上一版本** | v1.1.5 (2026-04-01)                   |
| **变更类型** | 重大更新                                  |
| **技能位置** | `~/.openclaw/skills/complaint-order/` |

***

### 🎉 重大更新

**对比版本**: v1.1.5 → v2.3.0

***

### 🔥 核心架构重构

#### 1. Token 管理机制升级

**v1.1.5** - 硬编码 Token

```javascript
const TOKEN = "90211116040f4dcd88fe54cba018330a";  // 固定 Token
```

**v2.3.0** - 401 自动刷新

```javascript
async getNewToken() {
  const res = await axios.post('https://api.lianok.com/common/v1/user/login', {
    password: "您的密码",  // ⚠️ 请修改为您自己的密码
    phone: "您的手机号",  // ⚠️ 请修改为您自己的手机号
    system: "operation",
    type: "password"
  });
  return res.data?.data?.accessToken || null;
}
```

**优势**:

- ✅ Token 永不过期（自动刷新）
- ✅ 无需手动更新代码
- ✅ 减少因 Token 失效导致的查询失败

> ⚠️ **注意**: 示例中的账号密码仅为演示，使用时请修改为您自己的火脸运营后台账号。

***

#### 2. 订单号解析规则升级

**v1.1.5** - 无日期解析，查询 6 个月数据

```javascript
function getMonthRange(monthsAgo) {
  // 查 6 个月：近 1 月 → 上 1 月 → ... → 前 5 月
  const timeRange = getMonthRange(monthsAgo);
}
```

**问题**:

- ❌ 每次查询 6 个月数据，API 调用量大
- ❌ 查询速度慢（6 轮 API 请求）
- ❌ 无法精准定位订单日期

**v2.3.0** - 智能日期解析，精准查询

```javascript
getOrderDate(orderNo) {
  // 规则 1: 1026xxx → 年第几天
  if (/^1026\d{3}/.test(orderNo)) {
    const dayOfYear = parseInt(orderNo.slice(4, 7), 10);
    // 解析为具体日期
  }
  
  // 规则 2: 42000xxxxx → 第 10-17 位
  if (/^42000/.test(orderNo) && orderNo.length >= 18) {
    const dateStr = orderNo.slice(10, 18);
    // 解析为 YYYY-MM-DD
  }
  
  // 规则 3: 20xxxxxx → 前 8 位
  if (/^20\d{2}/.test(orderNo)) {
    const dateStr = orderNo.slice(0, 8);
    // 解析为 YYYY-MM-DD
  }
}
```

**优势**:

- ✅ 精准查询单日数据（1 次 API 请求）
- ✅ 查询速度提升 6 倍
- ✅ 减少 API 调用量 83%

***

#### 3. 订单号格式支持扩展

| 规则   | 订单号前缀        | v1.1.5  | v2.3.0 |
| ---- | ------------ | ------- | ------ |
| 规则 1 | `1026xxx`    | ⚠️ 模糊查询 | ✅ 精准解析 |
| 规则 2 | `42000xxxxx` | ⚠️ 模糊查询 | ✅ 新增解析 |
| 规则 3 | `20xxxxxx`   | ❌ 不支持   | ✅ 新增支持 |

**新增规则 3 示例**:

```
订单号：2026040223001419901446808099
解析：前 8 位 = 2026-04-02
查询：2026-04-02 00:00:00 ~ 23:59:59
```

***

### 🐛 Bug 修复

#### 1. 时区问题修复

**问题**: `toISOString()` 返回 UTC 时间，导致日期差 1 天

**v1.1.5**: 未涉及（无日期解析）

**v2.3.0 修复**:

```javascript
// 修复前（UTC 时间）
const ymd = date.toISOString().slice(0, 10);  // 2026-03-21 ❌

// 修复后（本地时间）
const ymd = date.getFullYear() + '-' + 
            String(date.getMonth() + 1).padStart(2, '0') + '-' + 
            String(date.getDate()).padStart(2, '0');  // 2026-03-22 ✅
```

**验证**:

```
订单号：1026081200001329
年第 81 天 = 2026-03-22 ✅
```

***

### 📊 性能对比

| 指标       | v1.1.5  | v2.3.0    | 提升    |
| -------- | ------- | --------- | ----- |
| API 调用次数 | 12 次/订单 | 2 次/订单    | 83% ↓ |
| 查询耗时     | \~6 秒   | \~1 秒     | 83% ↓ |
| Token 管理 | 手动更新    | 自动刷新      | ✅     |
| 订单号支持    | 模糊匹配    | 3 种格式精准解析 | ✅     |

***

### 📝 输出格式优化

**v1.1.5**:

```
消费者联系方式：XXX
微信订单号/火脸订单号：XXX
查询结果：XXX
```

**v2.3.0**:

```
所属服务商：XXX
商户 ID：XXX 商户名称：XXX 存在 XXX 通道投诉
消费者联系方式：XXX
火脸订单号/官方订单号：XXX  ← 智能判断
订单金额：XXX
支付时间：XXX
投诉内容：XXX
```

**改进**:

- ✅ 新增"所属服务商"字段
- ✅ 智能判断订单号类型（火脸/官方）
- ✅ 信息更完整（商户 ID + 名称 + 通道）

***

### 🔧 代码结构优化

**v1.1.5**:

```javascript
// 全局常量
const API_URL = "...";
const TOKEN = "...";

// 独立函数
function getMonthRange() {...}
async function queryOrder() {...}
function parseMsg() {...}
function formatOutput() {...}
async function execute() {...}
```

**v2.3.0** - 模块化封装:

```javascript
module.exports = {
  meta: { ... },
  triggers: { ... },
  
  async getNewToken() {...},
  getOrderDate(orderNo) {...},
  parseMsg(text) {...},
  formatOutput(data, telephone, orderNo, complaint) {...},
  async execute(context) {...}
};
```

**优势**:

- ✅ 符合 OpenClaw 技能规范
- ✅ 支持技能元信息管理
- ✅ 便于测试和维护

***

### 📁 新增文件

| 文件               | 说明                   |
| ---------------- | -------------------- |
| `README.md`      | 技能使用说明               |
| `CHANGELOG.md`   | 更新日志（本文件）            |
| `SKILL.md`       | OpenClaw 技能描述（标准化格式） |
| `更新报告-v2.3.0.md` | 详细更新报告               |

***

## v1.1.5 (2026-04-01)

### 功能特性

- ✅ 支持投诉信息解析（联系方式、投诉内容、订单号）
- ✅ 查询 6 个月数据（避免遗漏）
- ✅ 支持 orderNo + topChannelOrderNo 双重查询
- ✅ 批量处理多条投诉

### 已知问题

- ❌ Token 需要手动更新
- ❌ 查询速度慢（6 轮 API 请求）
- ❌ 订单号格式支持有限
- ❌ 输出信息不够完整

***

## 📊 完整对比表

| 功能项          | v1.1.5  | v2.3.0                     | 状态 |
| ------------ | ------- | -------------------------- | -- |
| **Token 管理** | 硬编码     | 401 自动刷新                   | 🆕 |
| **订单号规则 1**  | 模糊查询    | 精准解析（年第几天）                 | ⬆️ |
| **订单号规则 2**  | 模糊查询    | 精准解析（第 10-17 位）            | 🆕 |
| **订单号规则 3**  | 不支持     | 精准解析（前 8 位）                | 🆕 |
| **查询范围**     | 6 个月    | 单日                         | ⬆️ |
| **API 调用**   | 12 次/订单 | 2 次/订单                     | ⬆️ |
| **查询速度**     | \~6 秒   | \~1 秒                      | ⬆️ |
| **时区处理**     | N/A     | 本地时间                       | 🐛 |
| **输出格式**     | 基础      | 增强（服务商 + 智能判断）             | ⬆️ |
| **代码结构**     | 函数式     | 模块化                        | ⬆️ |
| **文档**       | 无       | README + CHANGELOG + SKILL | 🆕 |

***

## 🚀 升级建议

### 从 v1.1.5 升级

1. **备份旧版本**
   ```bash
   cp -r complaint-order complaint-order-v1.1.5-backup
   ```
2. **替换文件**
   - 覆盖 `index.js`
3. **测试验证**
   ```bash
   node run.js
   ```
4. **验证 3 种订单号格式**
   - 1026 开头 ✅
   - 42000 开头 ✅
   - 20 开头 ✅

### 首次安装

技能已位于标准目录：

```
~/.openclaw/skills/complaint-order/
```

安装依赖：

```bash
cd ~/.openclaw/skills/complaint-order
npm install
```

***

## 📞 技术支持

| 项目         | 值                                              |
| ---------- | ---------------------------------------------- |
| **当前版本**   | v2.3.1                                         |
| **作者**     | duheng                                         |
| **更新日期**   | 2026-04-09                                     |
| **上一版本**   | v2.3.0 (2026-04-03)                            |
| **技能位置**   | `~/.openclaw/skills/complaint-order/`          |
| **GitHub** | <https://github.com/duheng-ai/complaint-order> |

***

**最后更新**: 2026-04-09 09:45
