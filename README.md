# AITestLab

> 基于 MCP + RAG 的 AI 测试自动化平台：从需求文档自动生成测试用例与 Playwright 脚本，支持知识库检索增强，开箱即用的 MCP Server 实现。
> AI-powered test automation platform built on MCP + RAG. Auto-generate test cases & Playwright scripts from requirement docs. Out-of-the-box MCP Server implementation.

[![backend](https://img.shields.io/badge/backend-FastAPI-009688)](https://fastapi.tiangolo.com/)
[![frontend](https://img.shields.io/badge/frontend-Vue%203%20%2B%20Vite-42b883)](https://vuejs.org/)
[![license](https://img.shields.io/badge/license-MIT-blue)](./LICENSE)

---

## 项目定位

很多"AI 测试工具"本质上是把需求丢给大模型聊一句，输出不可复现、无法追责。
AITestLab 想解决的是工程化问题：**让 AI 的每一次输出都有检索依据、有执行结果、有报告可查**。

- 知识库层：需求 / 接口文档 / 历史 Bug / 测试报告 / 日志 / 规范，统一切片入库，带 source type 元数据
- 生成层：用例生成、接口测试设计、可测性分析，全部走 RAG 检索上下文，减少幻觉
- 执行层：pytest 驱动接口场景执行，产出 JUnit XML / Allure 兼容结果
- 反馈层：解析执行结果 → 失败归因 → 生成 Bug 报告 → 回写知识库（闭环）
- 集成层：核心动作封装为 MCP tools，可被 Agent / IDE 直接编排

核心闭环：

```text
测试知识入库 -> RAG 检索 -> AI 生成测试用例
  -> pytest 自动化执行 -> JUnit / Allure 报告解析
  -> 失败原因分析 -> Bug 报告草稿生成
  -> Vue 前端 / CI 展示
```

## 功能一览

| 模块 | 能力 | 说明 |
|---|---|---|
| 概览 Dashboard | 用例数、执行数、通过率、趋势 | 平台入口页 |
| 接口测试中心 | 接口目录、环境变量、Query/Headers/Body、断言、Mock、cURL 导入、AI 用例裂变 | 对标 Postman / Apifox 的核心工作面 |
| API 环境管理 | 多环境配置与切换 | 支持 dev / test / staging |
| 自动化执行 | 页面触发后端执行 pytest 场景，产出报告 | 执行与产物分离 |
| 报告解析 | 解析 JUnit XML，识别 Allure results / report | 平台可直接消费测试结果 |
| 知识库 | 多 source type 文档入库、检索 | 服务层已按 RAG 结构设计 |
| AI 助手 | 用例生成、接口测试设计、失败分析、Bug 报告、可测性分析 | 输出带检索依据 |
| 测试用例管理 | 用例 CRUD、标签、批量操作 | —— |
| Web / App 测试 | 测试计划与 dry-run 执行编排 | UI 自动化当前为 dry-run adapter |
| 性能测试 | 场景配置与结果展示 | —— |
| CI/CD | GitHub Actions 跑回归并上传报告 artifact | 体现持续集成意识 |
| 平台设置 | 平台配置、LLM 配置 | —— |

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Vue 3、Vite、TypeScript、Vue Router |
| 后端 | FastAPI、Pydantic、Uvicorn |
| AI / 检索 | RAG（文档切分 + source type 元数据 + 可替换向量库）、jieba、ragas |
| MCP | MCP Server、tool schema、结构化 JSON 输出 |
| 测试执行 | pytest、接口测试 adapter、UI dry-run adapter |
| 报告 | JUnit XML、Allure-compatible results、Allure HTML artifact |
| 旧版工作台 | Streamlit（保留用于快速 demo） |

## 快速开始

### 环境要求

- Python 3.10+
- Node.js 18+
- （可选）Allure CLI —— 仅生成 Allure HTML 报告时需要

### 方式一：Windows 一键启动（推荐）

```bat
:: 首次仅需安装依赖
python -m venv .venv
.venv\Scripts\python.exe -m pip install -e ".[dev]"
cd frontend\qualitypilot-web
npm install
cd ..\..

:: 之后每次双击即可
start_qualitypilot.bat
```

启动器会自动判断：缺后端就起后端、缺前端就起前端、都已在跑就只打开页面；
就绪后自动用本机浏览器打开 <http://127.0.0.1:5173>。
所有过程写入 `logs\launcher.log`、`logs\api.log`、`logs\web.log`，出问题直接看日志。

关闭服务：

```bat
stop_qualitypilot.bat
```

### 方式二：手动启动（跨平台）

```bash
# 终端 1 —— 后端
.venv/Scripts/python.exe -m uvicorn src.api.main:app --host 127.0.0.1 --port 8000

# 终端 2 —— 前端
cd frontend/qualitypilot-web && npm run dev
```

| 地址 | 用途 |
|---|---|
| <http://127.0.0.1:5173> | 前端界面 |
| <http://127.0.0.1:8000/docs> | 后端 OpenAPI 文档 |
| <http://127.0.0.1:8000/api/health> | 健康检查 |

> 注意：必须前后端一起启动。只开前端会得到 `Failed to fetch`，页面数据全是 0。

## 目录结构

```
.
├── src/
│   ├── api/                 # FastAPI 应用：routers + services
│   │   ├── main.py
│   │   ├── routers/         # api_testing / automation / knowledge / reports / test_cases ...
│   │   └── services/
│   ├── core/                # 配置、平台设置
│   ├── ingestion/           # 文档解析与切片入库
│   ├── libs/
│   ├── mcp_server/          # MCP Server 与 tools 实现
│   └── observability/
├── frontend/qualitypilot-web/   # Vue 3 + Vite 前端
├── tests/                   # unit / integration / e2e / automation
├── scripts/                 # 启动、入库、评测、报告生成等脚本
├── config/                  # 平台与环境配置
├── docs/                    # 开发过程与模块文档
├── start_qualitypilot.bat   # Windows 一键启动
├── stop_qualitypilot.bat    # 停止服务
├── run_api.cmd / run_web.cmd
└── logs/                    # 运行日志（不入库）
```

## 架构概览

```
  Vue 3 (5173)
      │  /api  (Vite proxy)
      ▼
  FastAPI (8000) ──── routers ──── services
      │                              │
      │                              ├─► RAG 检索（知识库切片 + 元数据）
      │                              ├─► AI 助手（用例生成 / 失败分析 / Bug 报告）
      │                              └─► 执行器（pytest 场景）─► JUnit XML / Allure
      │
  MCP Server ──── 10 个 tools（可被 Agent / IDE 调用）
```

### MCP 工具清单

`generate_test_cases`、`retrieve_test_context`、`run_api_tests`、`get_test_report`、
`analyze_failure`、`generate_bug_report`、`query_knowledge_hub`、`query_failed_cases`、
`list_collections`、`get_document_summary`

详见 [docs/mcp_tools.md](docs/mcp_tools.md)。

## 我的改造路线

> 从上游原型起步，以下是按优先级推进的改造计划；完成后逐项打勾并补充实现说明。

**阶段一：工程化与可运行性**

- [x] Windows 一键启动 / 停止脚本，启动日志可查
- [x] README 重写、LICENSE / NOTICE 合规补齐
- [ ] 补齐前端与后端配置说明，做到 clone 后零手动改配置
- [ ] CI 跑通 lint + pytest，README 挂上真实状态徽章

**阶段二：把"演示级"能力换成"真能力"**

- [ ] 知识库检索：关键词匹配 → 向量检索（Chroma 已在依赖内）+ 重排，并加召回率评测
- [ ] UI 自动化：dry-run adapter → Playwright 真实执行，产出截图与 trace
- [ ] 用例生成：接入真实 LLM，用 ragas 做生成质量评测，输出可复现报告
- [ ] 失败分析：建立归因准确率基线数据集，量化效果而非"看起来对"

**阶段三：做出差异化**

- [ ] 选定一个垂直场景做深（接口文档 → 可执行 pytest 用例 → 覆盖率回流）
- [ ] 增加效果看板：用例命中率、失败归因准确率、执行时长分布
- [ ] 输出可复现的 benchmark，给出改造前后的对比数据

## 当前边界与已知问题

- 前端是测试平台原型，不是企业级权限系统（无 RBAC / 审计日志）
- 知识库默认使用稳定可演示的关键词检索，向量库接口已预留
- UI 自动化当前为 dry-run adapter，只输出执行计划
- Allure HTML 报告需本机安装 Allure CLI；CI 中由 artifact 提供
- CI 工作流配置暂存于 `docs/ci/github-actions-ci.yml`，复制回 `.github/workflows/`
  即可启用（首次推送所用凭据缺少 GitHub 要求的 `workflow` 权限）

## 来源与许可

本项目是基于开源项目的二次开发版本：

- 上游：[leo159363/AI-driven-test-automation-platform](https://github.com/leo159363/AI-driven-test-automation-platform)（原项目名 QualityPilot）
- 上游许可证：**MIT**（声明于其 `pyproject.toml`）
- 分叉基点：`e723f71e6025269650d432ae4c8f8cc5140ff2a1`

上游原始代码著作权归原作者所有；本仓库的修改部分著作权归 Yolanda Chen 所有。
本项目整体以 [MIT](./LICENSE) 发布，完整来源说明与修改登记见 [NOTICE](./NOTICE)。

## 致谢

感谢上游作者公开这套完整的测试平台实现，为本项目提供了起点与架构参考。
