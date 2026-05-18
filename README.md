# HRMS-Web 企业人事管理系统（前端）

<p align="center">
  <img src="https://img.shields.io/badge/Vue-3.5-4FC08D?logo=vue.js" alt="Vue 3" />
  <img src="https://img.shields.io/badge/Vite-7-646CFF?logo=vite" alt="Vite" />
  <img src="https://img.shields.io/badge/Element%20Plus-2.13-409EFF?logo=element" alt="Element Plus" />
  <img src="https://img.shields.io/badge/ECharts-6-AA344D?logo=apacheecharts" alt="ECharts" />
  <img src="https://img.shields.io/badge/Pinia-3-FFD859" alt="Pinia" />
</p>

## 📖 项目简介

HRMS-Web 是一套面向中小企业的人事管理系统前端，基于 Vue 3 生态构建。系统覆盖组织管理、考勤、薪酬、OA 审批、权限配置和数据报表等核心人事场景，并集成了具有独立人格设定的 AI 智能助手「亚托莉」，支持自然语言查询公司数据、天气查询和 AI 代理执行操作。

## ✨ 核心功能

### 🏢 组织与人事管理

- **员工管理** — 员工信息录入、编辑、状态管理
- **部门管理** — 组织架构维护、部门层级管理
- **职位管理** — 岗位定义与职位体系配置

### 📅 考勤管理

- **考勤记录** — 打卡记录查看、考勤状态统计
- **请假管理** — 请假申请、多级审批流转、撤销操作

### 💰 薪酬管理

- **薪资记录** — 工资条查看、提交审批、发放流程
- **薪资配置** — 薪资计算规则维护、配置审批

### 🔐 权限管理

- **用户管理** — 系统账号创建与维护
- **角色管理** — 角色定义与权限码分配
- **部门权限模板** — 按部门批量配置权限
- **模块数据范围** — 控制不同身份可见的数据范围（本人/本部门/全公司）
- **审批规则** — 可配置的多级审批链条（支持请假、薪资等业务类型）

### 📊 数据中心

- **Dashboard 仪表盘** — 员工统计、部门分布、考勤概览、待办事项
- **数据报表** — ECharts 可视化图表，多维度经营数据展示

### 🤖 智能助手「亚托莉」

系统集成了一个具有完整人格设定的 AI 聊天助手，核心能力包括：

#### 💬 智能聊天

- 基于《ATRI -My Dear Moments-》角色设定，亚托莉陪伴式对话
- 情绪安抚、日常聊天、流程解释等多场景自然交互
- 聊天记录持久化，刷新页面或重新登录后自动恢复历史

#### 📊 公司数据实时查询

- **全业务域覆盖** — 员工、部门、考勤、请假、薪资、审批规则等
- **动态数据获取** — 每次回答实时查询数据库最新数据，无需重启服务
- **权限边界控制** — 严格按照当前用户角色和数据范围返回信息
- **数据来源标注** — 回答中标注数据来源，区分系统事实与通用建议

#### 🌤️ 天气查询

- 集成高德地图天气 API，支持全国主要城市实时天气查询
- 自然语言识别城市名称，如"今天成都天气怎么样？"

#### 🤖 AI 代理执行（Agent）

- **自然语言下达指令** — 如"帮我提交 2 天病假申请"、"为财务专员增加薪资记录查看权限"
- **结构化执行计划** — Agent 先生成操作步骤、影响范围、风险等级和回滚方案
- **人工审批门禁** — 用户确认后才执行，确保操作安全可控
- **全量审计日志** — 记录每一步执行过程和结果

#### 🎨 现代化 UI

- 角色 Hero 区 + 人物资料卡 + 聊天区三栏布局
- 思考状态动画、消息来源提示、建议问题列表
- 模型状态实时显示

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Vue 3 (Composition API) |
| 构建工具 | Vite 7 |
| UI 组件库 | Element Plus 2.13 |
| 状态管理 | Pinia 3 |
| 路由 | Vue Router 4 |
| HTTP 客户端 | Axios |
| 图表 | ECharts 6 + vue-echarts |
| 图标 | @element-plus/icons-vue |

## 🚀 快速开始

### 环境要求

- Node.js >= 20.19.0 或 >= 22.12.0

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/your-username/HRMS-web.git
cd HRMS-web

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

### 后端配合

前端默认连接 `http://localhost:8080` 后端服务，请确保 [HRMS-backend](https://github.com/your-username/HRMS-backend) 已启动。

## 📁 项目结构

```
src/
├── api/                # API 接口层
│   ├── aiChat.js       # AI 聊天接口
│   ├── auth.js         # 认证接口
│   ├── employee.js     # 员工接口
│   ├── attendance.js   # 考勤接口
│   ├── leave.js        # 请假接口
│   ├── salaryRecord.js # 薪资记录接口
│   └── ...
├── components/         # 公共组件
│   ├── ai/             # AI 助手组件
│   │   └── AtriChatPanel.vue
│   ├── dashboard/      # 仪表盘组件
│   └── icons/          # 图标组件
├── layout/             # 布局组件
├── router/             # 路由配置（含权限守卫）
├── stores/             # Pinia 状态管理
├── utils/              # 工具函数
└── views/              # 页面视图
    ├── AiAssistant.vue # AI 助手页面
    ├── Dashboard.vue   # 仪表盘
    ├── Login.vue       # 登录页
    ├── Report.vue      # 数据报表
    ├── base/           # 基础信息管理
    ├── attendance/     # 考勤管理
    ├── salary/         # 薪酬管理
    └── permission/     # 权限管理
```

## 🔒 权限控制模型

系统采用四层权限协同模型：

1. **角色权限** — 控制菜单和按钮的可见性（如 `attendance:leave:approve`）
2. **身份标签** — 标记业务身份（如 HR_SPECIALIST、MANAGER）
3. **模块数据范围** — 控制可见数据范围（本人/本部门/全公司）
4. **审批规则** — 决定业务单据的流转路径

前端路由守卫根据 `meta.permission` 控制页面访问，按钮级权限通过 `v-if` 动态渲染。

## 📄 License

MIT
