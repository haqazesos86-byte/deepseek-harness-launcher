# 🐋 DeepSeek Harness 一键部署（Windows）

在 Windows 上**一站式**完成 DeepSeek Harness 的部署：自动检验 Node.js 环境 → 没有就帮你装 → 再安装 `@deepseek-ai/dsh` → 在桌面创建带官方黑色鲸鱼图标的快捷方式，**双击即可打开 Harness Web UI**。

> 本仓库源自一次真实排障：`npx @deepseek-ai/dsh web` 常见的问题不是"卡"，而是**端口 3080 被已运行的实例占用**（报 `EADDRINUSE`），或**浏览器标签开在了服务启动之前**（显示"无法访问此页面"）。本方案用一条启动器把这些坑全部绕开。

---

## ✨ 功能特性

- **Node.js 环境检验（部署前提）**：先检测 `node --version`，没有则自动用 winget 安装 Node.js LTS；没有 winget 则给出官方下载引导。
- **一键安装 Harness**：全局安装 `@deepseek-ai/dsh` 并验证版本。
- **桌面黑鲸鱼图标**：自动下载/内置 DeepSeek 官方鲸鱼图标（多尺寸 `.ico`），桌面生成 `DeepSeek Harness` 快捷方式，双击即用。
- **永不报"无法访问"**：启动器先探测 3080 端口 —— 已在运行就直接开浏览器；未运行才静默拉起服务，等它就绪（最长 120 秒）再开浏览器。
- **幂等**：重复双击不会重复起服务，只会再次打开页面。

---

## 🚀 快速开始

### 方式一：双击安装（最简单）

下载本仓库后，双击 **`install.bat`**，按提示完成即可。

### 方式二：命令行安装

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File setup.ps1
```

安装完成后，桌面上会出现 **`DeepSeek Harness`** 图标，双击它即可打开 **http://127.0.0.1:3080/** 。

> 首次启动服务需要冷启动约 **30~60 秒**（这期间无界面属正常），之后双击都是秒开。

---

## 📁 文件说明

| 文件 | 作用 |
|------|------|
| `install.bat` | 双击入口，调起 `setup.ps1` |
| `setup.ps1` | 一键部署：Node 检验 → 装 Node → 装 dsh → 验证 → 建桌面图标 |
| `launcher.ps1` | 桌面双击后真正执行的启动器（探测端口 → 起服务 → 开浏览器） |
| `make-shortcut.ps1` | 生成桌面快捷方式（可重复运行，用于重建图标） |
| `assets/harness.ico` | DeepSeek 黑鲸鱼图标（16~256 多尺寸） |
| `assets/harness-favicon.svg` | 图标源文件（SVG） |

---

## 🔍 工作原理（启动器逻辑）

双击 `DeepSeek Harness` 图标后：

```
1. 探测 http://127.0.0.1:3080/ 是否已响应
   ├─ 已响应 → 直接打开浏览器，结束（秒开）
   └─ 未响应 → 执行下一步
2. 定位 dsh 入口（npm 全局目录 → 常见安装路径 → npx 兜底）
3. 隐藏窗口静默启动 dsh web
4. 轮询等待服务就绪（最长 120 秒）
5. 打开浏览器 → http://127.0.0.1:3080/
```

---

## ❓ 常见问题

**Q1：双击后提示端口被占用 / `EADDRINUSE`？**
说明已有一个 Harness 实例在运行，**直接去访问 http://127.0.0.1:3080/ 即可**，不必重复启动。启动器本身已自动处理这种情况。

**Q2：浏览器显示"无法访问此页面"？**
- 大概率是标签页开在了服务启动之前。按 **F5**（或 **Ctrl+F5** 强制刷新）即可。
- 若持续连不上，确认服务是否还在（重启电脑后需重新双击图标）。
- 建议访问 `127.0.0.1`，避免 `localhost` 走 IPv6 解析。

**Q3：npm 提示 `allow-scripts` 策略跳过了部分 install 脚本？**
少数机器会启用 npm 的脚本白名单。若 `dsh` 功能异常，可补跑：
```powershell
npm install -g --allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs @deepseek-ai/dsh
```

**Q4：如何停止 Harness 服务？**
任务管理器 → 结束对应的 `node.exe` 进程（监听 3080 端口的那个）。或重启电脑。

**Q5：我把仓库文件夹挪了位置，快捷方式失效？**
快捷方式记录的是绝对路径。移动后重新运行一次 `make-shortcut.ps1` 即可重建。

**Q6：手动命令到底等价于什么？**
```powershell
node --version                          # 1. 检验 Node
npm install -g @deepseek-ai/dsh         # 2. 安装 Harness
dsh web                                 # 3. 启动服务（保持窗口开启）
# 然后浏览器访问 http://127.0.0.1:3080/
```

---

## 📌 环境要求

- Windows 10 / 11（PowerShell 5.1+）
- 能访问 npm registry（国内可配置 npmmirror 加速）
- 无需管理员权限（winget 装 Node 除外）

---

## ⚖️ 许可

MIT License。DeepSeek 图标版权归 DeepSeek 所有，仅用于快捷方式展示。
