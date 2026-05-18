<script setup>
import { onMounted, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { planTaskApi, approveAndExecuteApi, listTaskHistoryApi, cancelTaskApi, deleteTaskApi } from '@/api/agentTask'

const userStore = useUserStore()

// 状态
const command = ref('')
const planning = ref(false)
const executing = ref(false)
const currentTask = ref(null)
const executionLogs = ref([])
const historyTasks = ref([])
const historyLoading = ref(false)

// 启动时加载历史任务
onMounted(async () => {
  await loadHistory()
})

async function loadHistory() {
  if (!userStore.user?.userId) return
  historyLoading.value = true
  try {
    const list = await listTaskHistoryApi(userStore.user.userId)
    if (list && list.length > 0) {
      historyTasks.value = list.map(task => ({
        taskId: task.taskId,
        command: task.commandText,
        status: task.status,
        result: task.resultSummary,
        plan: task.plan,
        logs: task.logs || [],
        time: task.logs?.[0]?.createTime || ''
      }))
    }
  } catch (error) {
    // 静默失败
  } finally {
    historyLoading.value = false
  }
}

// 常用指令示例
const exampleCommands = [
  '帮我提交 1 天事假申请，原因是个人事务',
  '帮我提交 2 天病假申请',
  '把今天的考勤补录为 09:00 签到 18:00 签退',
  '为财务专员增加薪资记录查看权限',
  '为普通员工移除角色管理权限'
]

// 计算属性
const hasTask = computed(() => currentTask.value !== null)
const isPlanned = computed(() => currentTask.value?.status === 'planned')
const isSucceeded = computed(() => currentTask.value?.status === 'succeeded')
const isFailed = computed(() => currentTask.value?.status === 'failed')
const isCancelled = computed(() => currentTask.value?.status === 'cancelled')
const isExecutable = computed(() => currentTask.value?.plan?.executable === true)

const riskLevelMap = {
  low: { label: '低风险', type: 'success' },
  medium: { label: '中风险', type: 'warning' },
  high: { label: '高风险', type: 'danger' }
}

const statusMap = {
  planned: { label: '待审批', type: 'warning' },
  executing: { label: '执行中', type: '' },
  succeeded: { label: '已完成', type: 'success' },
  failed: { label: '执行失败', type: 'danger' },
  cancelled: { label: '已取消', type: 'info' }
}

function getRiskInfo(level) {
  return riskLevelMap[level] || { label: level, type: 'info' }
}

function getStatusInfo(status) {
  return statusMap[status] || { label: status, type: 'info' }
}

// preview key 中文映射
const previewKeyMap = {
  leaveType: '请假类型',
  startDate: '开始日期',
  endDate: '结束日期',
  days: '天数',
  reason: '原因',
  attendanceDate: '考勤日期',
  clockIn: '签到时间',
  clockOut: '签退时间',
  remark: '备注',
  action: '操作',
  roleId: '角色ID',
  roleName: '角色名称',
  permissionId: '权限ID',
  permissionName: '权限名称'
}

function translateKey(key) {
  return previewKeyMap[key] || key
}

function useExample(text) { command.value = text }

// 生成执行计划
async function generatePlan() {
  const text = command.value.trim()
  if (!text) {
    ElMessage.warning('请输入你想让 AI 代理执行的操作指令')
    return
  }
  if (!userStore.user?.userId) {
    ElMessage.warning('登录信息不完整，无法使用 AI 代理')
    return
  }

  planning.value = true
  currentTask.value = null
  executionLogs.value = []

  try {
    const result = await planTaskApi({ userId: userStore.user.userId, command: text })
    currentTask.value = result
    executionLogs.value = result.logs || []

    if (!result.plan?.executable) {
      ElMessage.warning('当前指令无法执行，请查看警告信息')
    } else {
      ElMessage.success('执行计划已生成，请审核后决定是否执行')
    }
  } catch (error) {
    ElMessage.error(error.message || '生成计划失败，请稍后重试')
  } finally {
    planning.value = false
  }
}

// 审批并执行
async function approveAndExecute() {
  if (!currentTask.value?.taskId) return
  try {
    await ElMessageBox.confirm('确认执行此操作？执行后将直接修改系统数据。', '确认执行', {
      confirmButtonText: '批准并执行', cancelButtonText: '取消', type: 'warning'
    })
  } catch { return }

  executing.value = true
  try {
    const result = await approveAndExecuteApi(currentTask.value.taskId, {
      userId: userStore.user.userId, remark: ''
    })
    currentTask.value = result
    executionLogs.value = result.logs || []
    ElMessage.success('操作执行成功！')
    await loadHistory()
  } catch (error) {
    ElMessage.error(error.message || '执行失败')
  } finally {
    executing.value = false
  }
}

// 取消任务（持久化到后端）
async function rejectPlan() {
  if (currentTask.value?.taskId && currentTask.value?.status === 'planned') {
    try {
      await cancelTaskApi(currentTask.value.taskId, {
        userId: userStore.user.userId, remark: '用户主动取消'
      })
      await loadHistory()
    } catch (error) {
      // 静默处理
    }
  }
  currentTask.value = null
  executionLogs.value = []
  ElMessage.info('已取消该计划')
}

// 重新规划
function replan() {
  currentTask.value = null
  executionLogs.value = []
}

// 清空当前
function clearAll() {
  command.value = ''
  currentTask.value = null
  executionLogs.value = []
}

// 点击历史任务加载详情
function loadHistoryTask(task) {
  currentTask.value = {
    taskId: task.taskId,
    commandText: task.command,
    status: task.status,
    resultSummary: task.result,
    providerName: '',
    plan: task.plan,
    logs: task.logs
  }
  executionLogs.value = task.logs || []
  command.value = task.command
}

// 删除历史任务
async function deleteHistoryTask(task, event) {
  event.stopPropagation()
  if (!userStore.user?.userId) return
  try {
    await ElMessageBox.confirm('确定删除此任务记录？删除后不可恢复。', '确认删除', {
      confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning'
    })
  } catch { return }

  try {
    await deleteTaskApi(task.taskId, { userId: userStore.user.userId, remark: '' })
    historyTasks.value = historyTasks.value.filter(t => t.taskId !== task.taskId)
    if (currentTask.value?.taskId === task.taskId) {
      currentTask.value = null
      executionLogs.value = []
    }
    ElMessage.success('已删除')
  } catch (error) {
    ElMessage.error(error.message || '删除失败')
  }
}
</script>

<template>
  <div class="agent-panel">
    <div class="agent-header">
      <h3>🤖 AI 代理执行</h3>
      <p>用自然语言描述你想执行的操作，AI 会先生成执行计划，经你确认后才会执行。</p>
    </div>

    <!-- 输入区 -->
    <div class="input-section">
      <div class="section-title">📝 输入指令</div>
      <el-input v-model="command" type="textarea" :rows="3" placeholder="例如：帮我提交 2 天病假申请、把今天考勤补录为 09:00 签到 18:00 签退" :disabled="planning || executing" />
      <div class="input-actions">
        <el-button type="primary" :loading="planning" :disabled="!command.trim() || executing" @click="generatePlan">
          {{ planning ? '正在规划...' : '生成执行计划' }}
        </el-button>
        <el-button v-if="hasTask" plain @click="clearAll">清空</el-button>
      </div>
      <div class="examples">
        <span class="examples-label">常用示例：</span>
        <div class="examples-list">
          <el-tag v-for="item in exampleCommands" :key="item" effect="plain" class="example-tag" @click="useExample(item)">{{ item }}</el-tag>
        </div>
      </div>
    </div>

    <!-- 计划展示区 -->
    <div v-if="hasTask" class="plan-section">
      <div class="section-title">📋 执行计划</div>
      <div class="plan-card">
        <div class="plan-meta">
          <el-tag :type="getStatusInfo(currentTask.status).type" effect="dark">{{ getStatusInfo(currentTask.status).label }}</el-tag>
          <el-tag :type="getRiskInfo(currentTask.plan?.riskLevel).type" effect="plain">{{ getRiskInfo(currentTask.plan?.riskLevel).label }}</el-tag>
          <span v-if="currentTask.providerName" class="plan-provider">规划来源：{{ currentTask.providerName }}</span>
        </div>

        <div class="plan-block">
          <div class="plan-block-title">需求理解</div>
          <div class="plan-block-content">{{ currentTask.plan?.summary || currentTask.commandText }}</div>
        </div>

        <div v-if="currentTask.plan?.entities?.length" class="plan-block">
          <div class="plan-block-title">影响对象</div>
          <div class="plan-entities">
            <el-tag v-for="entity in currentTask.plan.entities" :key="entity.type + entity.id" effect="plain" type="info">{{ entity.type }}：{{ entity.name }}</el-tag>
          </div>
        </div>

        <div v-if="currentTask.plan?.preview && Object.keys(currentTask.plan.preview).length" class="plan-block">
          <div class="plan-block-title">操作预览</div>
          <div class="plan-preview">
            <div v-for="(value, key) in currentTask.plan.preview" :key="key" class="preview-item">
              <span class="preview-key">{{ translateKey(key) }}</span>
              <span class="preview-value">{{ value }}</span>
            </div>
          </div>
        </div>

        <div v-if="currentTask.plan?.steps?.length" class="plan-block">
          <div class="plan-block-title">执行步骤</div>
          <div class="plan-steps">
            <div v-for="step in currentTask.plan.steps" :key="step.stepNo" class="step-item">
              <span class="step-no">{{ step.stepNo }}</span>
              <span class="step-title">{{ step.title }}</span>
              <el-tag size="small" effect="plain">{{ step.method }}</el-tag>
            </div>
          </div>
        </div>

        <div v-if="currentTask.plan?.rollbackPlan?.length" class="plan-block">
          <div class="plan-block-title">回滚方案</div>
          <ul class="rollback-list">
            <li v-for="(item, idx) in currentTask.plan.rollbackPlan" :key="idx">{{ item }}</li>
          </ul>
        </div>

        <div v-if="currentTask.plan?.warnings?.length" class="plan-warnings">
          <el-alert v-for="(warning, idx) in currentTask.plan.warnings" :key="idx" :title="warning" type="warning" :closable="false" show-icon />
        </div>
      </div>
    </div>

    <!-- 审批执行区 -->
    <div v-if="isPlanned" class="approve-section">
      <div class="section-title">✅ 审批执行</div>
      <div class="approve-actions">
        <el-button type="success" size="large" :disabled="!isExecutable" :loading="executing" @click="approveAndExecute">批准并执行</el-button>
        <el-button size="large" @click="rejectPlan">拒绝执行</el-button>
        <el-button size="large" plain @click="replan">重新规划</el-button>
      </div>
      <div v-if="!isExecutable" class="approve-hint">⚠️ 当前计划无法执行，请查看上方警告信息</div>
    </div>

    <!-- 执行结果 -->
    <div v-if="isSucceeded || isFailed || isCancelled" class="result-section">
      <div class="section-title">{{ isSucceeded ? '✅ 执行结果' : isCancelled ? '🚫 已取消' : '❌ 执行失败' }}</div>
      <el-alert :title="currentTask.resultSummary || (isSucceeded ? '操作成功' : isCancelled ? '用户已取消该计划' : '操作失败')" :type="isSucceeded ? 'success' : isCancelled ? 'info' : 'error'" :closable="false" show-icon />
    </div>

    <!-- 审计日志 -->
    <div v-if="executionLogs.length" class="log-section">
      <div class="section-title">📜 审计日志</div>
      <div class="log-list">
        <div v-for="log in executionLogs" :key="log.logId" :class="['log-item', `log-${log.logLevel}`]">
          <span class="log-step">步骤 {{ log.stepNo }}</span>
          <span class="log-level">{{ log.logLevel.toUpperCase() }}</span>
          <span class="log-message">{{ log.message }}</span>
          <span class="log-time">{{ log.createTime }}</span>
        </div>
      </div>
    </div>

    <!-- 历史任务 -->
    <div v-if="historyTasks.length" class="history-section">
      <div class="section-title">📂 历史任务</div>
      <div class="history-list">
        <div v-for="task in historyTasks" :key="task.taskId" class="history-item" @click="loadHistoryTask(task)">
          <el-tag :type="getStatusInfo(task.status).type" size="small">{{ getStatusInfo(task.status).label }}</el-tag>
          <span class="history-command">{{ task.command }}</span>
          <span class="history-time">{{ task.time }}</span>
          <el-button size="small" type="danger" plain @click="deleteHistoryTask(task, $event)">删除</el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.agent-panel { display: flex; flex-direction: column; gap: 20px; height: 100%; overflow-y: auto; padding: 4px; }
.agent-header { text-align: center; padding-bottom: 16px; border-bottom: 1px solid rgba(148, 163, 184, 0.15); }
.agent-header h3 { margin: 0 0 8px; font-size: 22px; font-weight: 800; color: #17345c; }
.agent-header p { margin: 0; color: #59718d; font-size: 14px; line-height: 1.6; }
.section-title { font-size: 15px; font-weight: 700; color: #1e3a5f; margin-bottom: 12px; }
.input-section { display: flex; flex-direction: column; gap: 12px; }
.input-actions { display: flex; gap: 10px; }
.examples { display: flex; flex-direction: column; gap: 8px; }
.examples-label { font-size: 12px; color: #64748b; font-weight: 600; }
.examples-list { display: flex; flex-wrap: wrap; gap: 8px; }
.example-tag { cursor: pointer; transition: all 0.2s; font-size: 12px; }
.example-tag:hover { transform: translateY(-1px); box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); }
.plan-section { display: flex; flex-direction: column; gap: 12px; }
.plan-card { padding: 18px; border-radius: 16px; background: rgba(255, 255, 255, 0.92); border: 1px solid rgba(90, 129, 185, 0.15); box-shadow: 0 4px 16px rgba(15, 23, 42, 0.06); display: flex; flex-direction: column; gap: 16px; }
.plan-meta { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.plan-provider { font-size: 12px; color: #64748b; margin-left: auto; }
.plan-block { padding: 12px 14px; border-radius: 12px; background: rgba(241, 245, 249, 0.7); border: 1px solid rgba(148, 163, 184, 0.12); }
.plan-block-title { font-size: 13px; font-weight: 700; color: #475569; margin-bottom: 8px; }
.plan-block-content { font-size: 14px; color: #1e293b; line-height: 1.6; }
.plan-entities { display: flex; gap: 8px; flex-wrap: wrap; }
.plan-preview { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 8px; }
.preview-item { display: flex; align-items: center; gap: 8px; padding: 6px 10px; border-radius: 8px; background: rgba(255, 255, 255, 0.8); }
.preview-key { font-size: 12px; color: #64748b; font-weight: 600; min-width: 70px; }
.preview-value { font-size: 13px; color: #1e293b; font-weight: 500; }
.plan-steps { display: flex; flex-direction: column; gap: 8px; }
.step-item { display: flex; align-items: center; gap: 10px; padding: 8px 12px; border-radius: 10px; background: rgba(255, 255, 255, 0.8); }
.step-no { width: 24px; height: 24px; border-radius: 50%; background: linear-gradient(135deg, #337cf6, #31c3d0); color: #fff; font-size: 12px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.step-title { flex: 1; font-size: 13px; color: #334155; }
.rollback-list { margin: 0; padding-left: 20px; font-size: 13px; color: #475569; line-height: 1.8; }
.plan-warnings { display: flex; flex-direction: column; gap: 8px; }
.approve-section { padding: 16px; border-radius: 16px; background: rgba(240, 253, 244, 0.8); border: 1px solid rgba(34, 197, 94, 0.2); }
.approve-actions { display: flex; gap: 12px; flex-wrap: wrap; }
.approve-hint { margin-top: 10px; font-size: 13px; color: #d97706; }
.result-section { display: flex; flex-direction: column; gap: 12px; }
.log-section { display: flex; flex-direction: column; gap: 12px; }
.log-list { display: flex; flex-direction: column; gap: 6px; max-height: 200px; overflow-y: auto; padding: 12px; border-radius: 12px; background: rgba(15, 23, 42, 0.03); border: 1px solid rgba(148, 163, 184, 0.12); }
.log-item { display: flex; align-items: center; gap: 10px; padding: 6px 10px; border-radius: 8px; font-size: 12px; background: rgba(255, 255, 255, 0.7); }
.log-item.log-info { border-left: 3px solid #3b82f6; }
.log-item.log-warn { border-left: 3px solid #f59e0b; }
.log-item.log-error { border-left: 3px solid #ef4444; }
.log-step { font-weight: 700; color: #475569; min-width: 50px; }
.log-level { font-weight: 600; min-width: 40px; }
.log-info .log-level { color: #3b82f6; }
.log-warn .log-level { color: #f59e0b; }
.log-error .log-level { color: #ef4444; }
.log-message { flex: 1; color: #334155; }
.log-time { color: #94a3b8; font-size: 11px; white-space: nowrap; }
.history-section { display: flex; flex-direction: column; gap: 12px; }
.history-list { display: flex; flex-direction: column; gap: 8px; }
.history-item { display: flex; align-items: center; gap: 10px; padding: 10px 14px; border-radius: 10px; background: rgba(241, 245, 249, 0.6); border: 1px solid rgba(148, 163, 184, 0.1); cursor: pointer; transition: all 0.2s; }
.history-item:hover { background: rgba(226, 232, 240, 0.8); transform: translateY(-1px); box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.history-command { flex: 1; font-size: 13px; color: #334155; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.history-time { font-size: 11px; color: #94a3b8; white-space: nowrap; }
@media (max-width: 768px) {
  .plan-preview { grid-template-columns: 1fr; }
  .approve-actions { flex-direction: column; }
  .log-item { flex-wrap: wrap; }
  .log-time { width: 100%; }
}
</style>
