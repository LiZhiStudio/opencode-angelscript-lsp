# Angelscript LSP for OpenCode

为 [OpenCode](https://github.com/opencode-ai/opencode) 提供的 Angelscript 语言服务器。基于 [Hazelight 的 vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript) 扩展中的语言服务器构建。

### 给 OpenCode 智能体使用

让 OpenCode 智能体获取安装说明并自动配置：

```
Install and configure Angelscript LSP by following the instructions here:
curl -s https://raw.githubusercontent.com/LiZhiStudio/angelscript-lsp/refs/heads/main/docs/install-opencode.md
```

### 给 Claude Code 智能体使用

让 Claude Code 智能体获取安装说明并自动配置：

```
Install and configure Angelscript LSP by following the instructions here:
curl -s https://raw.githubusercontent.com/LiZhiStudio/angelscript-lsp/refs/heads/main/docs/install-claude-code.md
```

## 目录结构

```
angelscript-lsp/
├── build/                  # esbuild 构建产物
│   ├── server.js           #   LSP 服务器（已打包，可直接运行）
│   └── server.js.map       #   Source map（调试用）
├── start.js                # 入口脚本（require('./build/server.js')）
├── test-lsp.mjs            # LSP 连接测试脚本
├── update.ps1              # 一键更新脚本（从源码重新构建）
├── docs/                   # 文档
│   └── install.md          #   LLM 智能体安装说明
├── .gitignore
│
├── src/                    # TypeScript 源码
├── pegjs/                  # Angelscript 语法解析器
├── grammar/                # 语法节点类型定义
├── esbuild.js              # 构建配置
├── package.json            # npm 依赖
├── package-lock.json       # 依赖锁定
└── tsconfig.json           # TypeScript 配置
```

## 快速使用

### 1. 配置 OpenCode LSP

在 opencode 配置文件（`opencode.jsonc`）中添加：

```json
{
  "lsp": {
    "angelscript": {
      "command": ["node", "path/to/angelscript-lsp/start.js"],
      "extensions": [".as"]
    }
  }
}
```

### 2. 运行测试

```bash
node test-lsp.mjs
```

正常输出会显示 LSP 返回的 capabilities（自动补全、诊断、悬停提示等能力列表）。

### 3. 关于 UE 编辑器

LSP 在启动时会尝试通过 TCP（默认端口 27099）连接 Unreal Editor。连接成功后即可获得基于引擎类型信息的代码补全和诊断。**编辑器未运行时 LSP 仍可启动**，但类型信息有限。

在 UE 项目设置的 Angelscript 插件中配置 `Debug Port`（默认 27099），或通过启动参数 `-asdebugport=27099` 指定。

## 更新 LSP

### 从本地源码重新构建

```powershell
.\update.ps1
```

这会使用 `src/` 目录中的源码，通过 esbuild 重新打包生成 `server.js`。

### 从 Hazelight 官方仓库拉取最新源码后构建

```powershell
.\update.ps1 -Remote
```

这会自动克隆 [Hazelight/vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript) 仓库的最新代码，构建并同步到本仓库。

### 从本地已下载的扩展构建

```powershell
.\update.ps1 -SourcePath "D:\path\to\vscode-unreal-angelscript"
```

## LSP 功能

| 功能 | 说明 |
|---|---|
| 语法诊断 | `.as` 文件编译错误提示 |
| 自动补全 | 基于类型系统的代码补全（触发 `.` 和 `:`） |
| 悬停提示 | 类型和文档信息 |
| 跳转定义 | 跳转到符号定义 |
| 查找引用 | 查找所有引用位置 |
| 语义高亮 | 类型感知的语法高亮 |
| 重命名 | 符号重命名 |
| 签名帮助 | 函数参数提示 |
| 类型层次 | 类继承关系查看 |

## 构建原理

`start.js` → `require('./build/server.js')`，而 `server.js` 是 Hazelight 的 `language-server/src/server.ts` 通过 esbuild 打包后的产物（`bundle: true`，所有 npm 依赖内联），运行时仅依赖 Node.js 内置模块，无需额外安装。

## 许可

本仓库基于 Hazelight 的 [vscode-unreal-angelscript](https://github.com/Hazelight/vscode-unreal-angelscript) 构建，请参考原项目的许可条款。
