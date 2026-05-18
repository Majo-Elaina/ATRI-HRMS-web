<script setup>
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { chatWithAtriApi, getChatHistoryApi, clearChatHistoryApi, getProviderInfoApi } from '@/api/aiChat'
import AgentTaskPanel from './AgentTaskPanel.vue'

const props = defineProps({
  avatar: { type: String, required: true }
})

const userStore = useUserStore()
const chatViewportRef = ref(null)
const sending = ref(false)
const loading = ref(true)
const input = ref('')
const modelLabel = ref('加载中...')
const providerLabel = ref('加载中...')
const providerAvailable = ref(true)
const providerNotice = ref('')
const sourceHints = ref([])
const isSuggestionsExpanded = ref(true)

// Chat / Agent 模式切换
const activeMode = ref('chat')

const suggestionList = [
  '本公司员工总数是多少？',
  '请帮我概括一下当前系统都有哪些主要模块。',
  '如何请假？',
  '我本月的工资应该是多少？',
  '帮我总结一下我当前的岗位、部门和身份标签。',
  '最近请假审批规则是什么？',
  '考勤和请假数据主要能查到哪些内容？',
  '今天绵阳的天气怎么样？',
  '今天工作有点累，陪我聊聊天吧。'
]

const messages = ref([])

const chatHistoryPayload = computed(() =>
  messages.value
    .filter(item => item.role === 'user' || item.role === 'assistant')
    .slice(-12)
    .map(item => ({ role: item.role, content: item.content }))
)

watch(() => userStore.user?.userId, async (newUserId) => {
  if (newUserId) await loadHistory()
}, { immediate: true })

onMounted(async () => {
  await loadProviderInfo()
  if (userStore.user?.userId) await loadHistory()
  loading.value = false
})

async function loadProviderInfo() {
  try {
    const info = await getProviderInfoApi()
    modelLabel.value = info.model || '未连接'
    providerLabel.value = info.provider || '未配置'
    providerAvailable.value = info.providerAvailable !== false
  } catch (error) {
    modelLabel.value = '未连接'
    providerLabel.value = '未配置'
  }
}

async function loadHistory() {
  if (!userStore.user?.userId) return
  try {
    const history = await getChatHistoryApi(userStore.user.userId)
    if (history && history.length > 0) {
      messages.value = history.map(msg => ({
        id: `history-${msg.id}`,
        role: msg.role,
        content: msg.content,
        meta: msg.usedSystemData ? 'used-system-data' : 'chat-only'
      }))
    } else {
      messages.value = [{ id: 'welcome', role: 'assistant', content: '我是亚托莉。聊天、解释流程、读取系统里的只读数据，这些事情请交给我吧。', meta: 'ready' }]
    }
    scrollToBottom()
  } catch (error) {
    messages.value = [{ id: 'welcome', role: 'assistant', content: '我是亚托莉。聊天、解释流程、读取系统里的只读数据，这些事情请交给我吧。', meta: 'ready' }]
  }
}

function useSuggestion(text) { input.value = text }
function toggleSuggestions() { isSuggestionsExpanded.value = !isSuggestionsExpanded.value }

function pushMessage(message) {
  messages.value.push(message)
  scrollToBottom()
}

function scrollToBottom() {
  nextTick(() => {
    const el = chatViewportRef.value
    if (el) el.scrollTop = el.scrollHeight
  })
}

function buildFriendlyFallback() {
  return '我是亚托莉。虽然这次模型连接没有成功，不过高性能的我还是会先把系统里能确认的信息告诉你。你也可以稍后再试一次，我会继续认真接住你的问题。'
}

async function sendMessage() {
  const message = input.value.trim()
  if (!message || sending.value) return
  if (!userStore.user?.userId) {
    ElMessage.warning('当前登录信息不完整，暂时无法与亚托莉聊天。')
    return
  }

  pushMessage({ id: `user-${Date.now()}`, role: 'user', content: message })
  input.value = ''
  sending.value = true

  const thinkingId = `thinking-${Date.now()}`
  const thinkingMessages = [
    '亚托莉正在高性能思考中......',
    '让我来仔细分析一下......',
    '高性能的我正在处理你的问题......',
    '请稍等，我在认真思考......',
    '毕竟我是高性能的，马上就好......'
  ]
  pushMessage({ id: thinkingId, role: 'assistant', content: thinkingMessages[Math.floor(Math.random() * thinkingMessages.length)], meta: 'thinking' })

  try {
    const response = await chatWithAtriApi({ userId: userStore.user.userId, message, history: chatHistoryPayload.value })
    const idx = messages.value.findIndex(msg => msg.id === thinkingId)
    if (idx !== -1) messages.value.splice(idx, 1)

    modelLabel.value = response.model || '未连接'
    providerLabel.value = response.provider || '未配置'
    providerAvailable.value = response.providerAvailable !== false
    providerNotice.value = response.notice || ''
    sourceHints.value = response.sources || []

    pushMessage({ id: `assistant-${Date.now()}`, role: 'assistant', content: response.reply || buildFriendlyFallback(), meta: response.usedSystemData ? 'used-system-data' : 'chat-only' })
  } catch (error) {
    const idx = messages.value.findIndex(msg => msg.id === thinkingId)
    if (idx !== -1) messages.value.splice(idx, 1)
    providerAvailable.value = false
    providerNotice.value = error.message || '聊天服务暂时不可用'
    ElMessage.error(error.message || '亚托莉暂时没有回应，请稍后再试。')
    pushMessage({ id: `assistant-error-${Date.now()}`, role: 'assistant', content: buildFriendlyFallback(), meta: 'error' })
  } finally {
    sending.value = false
  }
}

async function clearConversation() {
  try {
    await ElMessageBox.confirm('确定要清空所有聊天记录吗？此操作不可恢复。', '确认清空', { confirmButtonText: '确定', cancelButtonText: '取消', type: 'warning' })
    await clearChatHistoryApi(userStore.user.userId)
    messages.value = [{ id: 'welcome-reset', role: 'assistant', content: '新的对话已经准备好了。请把想问的问题交给我吧。', meta: 'ready' }]
    sourceHints.value = []
    providerNotice.value = ''
    ElMessage.success('聊天记录已清空')
  } catch (error) {
    if (error !== 'cancel') ElMessage.error('清空失败，请稍后重试')
  }
}

function handleKeydown(event) {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    sendMessage()
  }
}
</script>

<template>
  <div class="chat-shell">
    <aside class="profile-card">
      <div class="portrait-ring">
        <img :src="avatar" alt="亚托莉头像" class="portrait" />
      </div>
      <div class="profile-copy">
        <div class="kicker">Atri / 亚托莉</div>
        <h2>高性能陪伴助手</h2>
        <p>温柔认真的高性能助手，擅长自然聊天与情绪陪伴。可以解释系统流程、查询权限范围内的数据，并用亚托莉独有的语气为你整理信息。</p>
      </div>
      <div class="capability-list">
        <div class="capability-item">
          <span>技术架构</span>
          <strong>支持 OpenAI 兼容接口与本地 Ollama 部署，可灵活切换模型源</strong>
          <div class="capability-desc">多provider架构设计，支持Qwen、DeepSeek、GPT等主流模型</div>
        </div>
        <div class="capability-item" :data-available="providerAvailable">
          <span>当前模型</span>
          <strong>{{ modelLabel }}</strong>
          <div class="capability-desc">{{ providerAvailable ? '模型运行正常，响应速度良好' : '模型连接异常，请检查配置' }}</div>
        </div>
        <div class="capability-item" :data-available="providerAvailable">
          <span>推理源</span>
          <strong>{{ providerLabel }}</strong>
          <div class="capability-desc">{{ providerAvailable ? '连接稳定，支持实时对话' : '连接不稳定，可能影响使用' }}</div>
        </div>
      </div>
    </aside>

    <section class="chat-card">
      <header class="chat-header">
        <div>
          <div class="chat-title">和亚托莉聊天</div>
          <p>请交给我吧，主人。无论是日常聊天还是系统数据查询。</p>
        </div>
        <div class="header-badges">
          <el-tag effect="dark" type="primary">高性能模式</el-tag>
          <el-tag effect="plain" type="success">陪伴聊天</el-tag>
        </div>
      </header>

      <div v-if="!providerAvailable || providerNotice" class="status-banner">
        <div class="status-title">{{ providerAvailable ? '模型已连接' : '模型服务暂时不可用' }}</div>
        <div class="status-copy">{{ providerNotice || '当前仍可使用后端只读数据兜底回答，但建议检查后端配置的模型 provider 是否可访问。' }}</div>
      </div>

      <!-- Chat 模式下的快捷提示 -->
      <div v-show="activeMode === 'chat'" class="suggestion-section">
        <button type="button" class="suggestion-toggle" @click="toggleSuggestions">
          <span class="suggestion-toggle-text">快捷提示</span>
          <span class="suggestion-toggle-icon">{{ isSuggestionsExpanded ? '▴' : '▾' }}</span>
        </button>
        <div v-show="isSuggestionsExpanded" class="suggestion-list">
          <button v-for="item in suggestionList" :key="item" type="button" class="suggestion-chip" @click="useSuggestion(item)">{{ item }}</button>
        </div>
      </div>

      <!-- 滑动视口容器 -->
      <div class="slide-container">
        <div class="slide-track" :class="{ 'show-agent': activeMode === 'agent' }">
          <!-- 左侧：Chat 聊天消息 -->
          <div ref="chatViewportRef" class="chat-viewport slide-panel">
            <div v-for="item in messages" :key="item.id" :class="['chat-row', item.role]">
              <img v-if="item.role === 'assistant'" :src="avatar" alt="亚托莉头像" class="bubble-avatar" />
              <div :class="['bubble', item.role]" :data-meta="item.meta">
                <div class="bubble-role">{{ item.role === 'assistant' ? '亚托莉' : '你' }}</div>
                <div class="bubble-content">{{ item.content }}</div>
              </div>
            </div>
          </div>
          <!-- 右侧：Agent 代理执行 -->
          <div class="agent-viewport slide-panel">
            <AgentTaskPanel />
          </div>
        </div>
      </div>

      <!-- Chat 模式下的数据来源 -->
      <div v-if="sourceHints.length && activeMode === 'chat'" class="source-strip">
        <span class="source-label">本轮读取：</span>
        <el-tag v-for="item in sourceHints" :key="item.type + item.title" effect="plain" type="info">{{ item.title }}</el-tag>
      </div>

      <!-- 底部操作栏 -->
      <footer class="composer">
        <!-- Chat 模式下显示输入框 -->
        <el-input
          v-show="activeMode === 'chat'"
          v-model="input"
          type="textarea"
          resize="none"
          :rows="2"
          placeholder="请交给我吧，主人。想聊什么或者问什么系统数据都可以。"
          @keydown="handleKeydown"
        />
        <div class="composer-actions">
          <span v-show="activeMode === 'chat'" class="composer-hint">Enter 发送，Shift + Enter 换行</span>
          <span v-show="activeMode === 'agent'" class="composer-hint">AI 代理模式：用自然语言下达操作指令</span>
          <div class="composer-buttons">
            <!-- Chat / Agent 切换按钮 -->
            <div class="mode-toggle">
              <button :class="['toggle-btn', { active: activeMode === 'chat' }]" @click="activeMode = 'chat'">Chat</button>
              <button :class="['toggle-btn', { active: activeMode === 'agent' }]" @click="activeMode = 'agent'">Agent</button>
            </div>
            <el-button v-show="activeMode === 'chat'" plain @click="clearConversation">清空对话</el-button>
            <el-button v-show="activeMode === 'chat'" type="primary" :loading="sending" @click="sendMessage">发送给亚托莉</el-button>
          </div>
        </div>
      </footer>
    </section>
  </div>
</template>

<style scoped>
.chat-shell {
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr);
  gap: 20px;
  height: 100%;
  padding: 20px;
  box-sizing: border-box;
  overflow: hidden;
}

.chat-shell, .chat-shell * { user-select: text; }
button, .el-button, .suggestion-chip, .toggle-btn { user-select: none; }

.profile-card, .chat-card {
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.88);
  border: 1px solid rgba(255, 255, 255, 0.68);
  box-shadow: 0 20px 40px rgba(15, 23, 42, 0.1);
  backdrop-filter: blur(18px);
  overflow: hidden;
}

.profile-card {
  padding: 24px 20px;
  display: flex;
  flex-direction: column;
  background: radial-gradient(circle at top, rgba(73, 165, 255, 0.22), transparent 38%), linear-gradient(180deg, rgba(242, 249, 255, 0.96), rgba(232, 243, 255, 0.9));
}

.portrait-ring {
  width: 90px; height: 90px; margin: 0 auto 18px; padding: 4px;
  border-radius: 50%;
  background: linear-gradient(135deg, #53b9ff, #4f7cff, #7be0d3);
  box-shadow: 0 12px 28px rgba(60, 118, 214, 0.2);
  flex-shrink: 0;
}
.portrait { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }

.profile-copy { text-align: center; flex-shrink: 0; margin-bottom: 20px; }
.kicker { display: inline-flex; padding: 5px 12px; border-radius: 999px; background: rgba(41, 98, 255, 0.12); color: #2855d9; font-size: 12px; font-weight: 700; letter-spacing: 0.08em; }
.profile-copy h2 { margin: 16px 0 12px; font-size: 24px; font-weight: 800; color: #163257; }
.profile-copy p { margin: 0; line-height: 1.7; color: #56708e; font-size: 14px; padding: 0 4px; }

.capability-list { display: grid; gap: 16px; flex: 1; min-height: 0; }
.capability-item { padding: 22px 18px; border-radius: 20px; background: rgba(255, 255, 255, 0.9); border: 1px solid rgba(90, 129, 185, 0.18); transition: all 0.25s ease; box-shadow: 0 4px 12px rgba(90, 129, 185, 0.08); }
.capability-item:hover { background: rgba(255, 255, 255, 0.98); border-color: rgba(90, 129, 185, 0.3); transform: translateY(-2px); box-shadow: 0 8px 20px rgba(90, 129, 185, 0.15); }
.capability-item span { display: block; margin-bottom: 8px; font-size: 13px; font-weight: 700; color: #6b7d93; letter-spacing: 0.5px; text-transform: uppercase; }
.capability-item strong { color: #17345c; line-height: 1.5; font-size: 15px; font-weight: 600; display: block; margin-bottom: 6px; }
.capability-desc { color: #7c8ba1; font-size: 12px; line-height: 1.4; font-style: italic; margin-top: 4px; }
.capability-item[data-available="true"] .capability-desc { color: #059669; }
.capability-item[data-available="false"] .capability-desc { color: #dc2626; }

.chat-card {
  display: flex; flex-direction: column; padding: 20px;
  background: radial-gradient(circle at top right, rgba(129, 211, 255, 0.18), transparent 28%), linear-gradient(180deg, rgba(250, 252, 255, 0.95), rgba(243, 248, 255, 0.9));
}

.chat-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; margin-bottom: 16px; flex-shrink: 0; }
.chat-title { font-size: 26px; font-weight: 800; color: #17345c; }
.chat-header p { margin: 6px 0 0; color: #59718d; font-size: 14px; }
.header-badges { display: flex; gap: 8px; flex-wrap: wrap; }

.status-banner { margin-bottom: 12px; padding: 12px 14px; border-radius: 16px; background: rgba(255, 244, 225, 0.92); border: 1px solid rgba(245, 158, 11, 0.18); color: #8a5c0c; flex-shrink: 0; }
.status-title { font-weight: 700; margin-bottom: 3px; font-size: 13px; }
.status-copy { line-height: 1.6; font-size: 12px; }

.suggestion-section { margin-bottom: 16px; flex-shrink: 0; }
.suggestion-toggle { width: 100%; display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 10px 14px; margin-bottom: 10px; border: 0; border-radius: 16px; background: rgba(50, 109, 233, 0.08); color: #1f3f8f; cursor: pointer; transition: background-color 0.18s ease; }
.suggestion-toggle:hover { background: rgba(50, 109, 233, 0.14); }
.suggestion-toggle-text { font-size: 13px; font-weight: 700; }
.suggestion-toggle-icon { font-size: 16px; line-height: 1; }
.suggestion-list { display: flex; flex-wrap: wrap; gap: 8px; }
.suggestion-chip { padding: 8px 12px; border: 0; border-radius: 999px; background: rgba(50, 109, 233, 0.08); color: #2855d9; cursor: pointer; transition: transform 0.18s ease, background-color 0.18s ease; font-size: 12px; }
.suggestion-chip:hover { transform: translateY(-1px); background: rgba(50, 109, 233, 0.14); }

/* 滑动容器 */
.slide-container { flex: 1; min-height: 0; overflow: hidden; position: relative; }
.slide-track {
  display: flex; width: 200%; height: 100%;
  transition: transform 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}
.slide-track.show-agent { transform: translateX(-50%); }
.slide-panel { width: 50%; height: 100%; overflow-y: auto; flex-shrink: 0; }

.chat-viewport { padding: 4px 4px 4px 0; }
.agent-viewport { padding: 4px; }

.chat-row { display: flex; margin-bottom: 12px; }
.chat-row.user { justify-content: flex-end; }
.bubble-avatar { width: 36px; height: 36px; margin-right: 10px; border-radius: 50%; object-fit: cover; box-shadow: 0 8px 16px rgba(71, 117, 208, 0.15); flex-shrink: 0; }
.bubble { max-width: min(75%, 600px); padding: 12px 14px; border-radius: 20px; box-shadow: 0 10px 24px rgba(20, 39, 73, 0.08); white-space: pre-wrap; line-height: 1.7; font-size: 14px; }
.bubble.assistant { border-top-left-radius: 10px; background: rgba(255, 255, 255, 0.9); color: #17345c; }
.bubble.user { border-top-right-radius: 10px; background: linear-gradient(135deg, #337cf6 0%, #31c3d0 100%); color: #fff; }
.bubble.assistant[data-meta="thinking"] { background: rgba(255, 248, 220, 0.95); border: 1px solid rgba(245, 158, 11, 0.2); color: #92400e; font-style: italic; animation: thinking-pulse 1.5s ease-in-out infinite; }
@keyframes thinking-pulse { 0%, 100% { opacity: 0.8; transform: scale(1); } 50% { opacity: 1; transform: scale(1.02); } }
.bubble-role { margin-bottom: 4px; font-size: 11px; font-weight: 700; letter-spacing: 0.06em; opacity: 0.75; }

.source-strip { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; margin: 4px 0 12px; flex-shrink: 0; }
.source-label { color: #64748b; font-size: 12px; }

.composer { padding-top: 16px; border-top: 1px solid rgba(148, 163, 184, 0.14); flex-shrink: 0; }
.composer-actions { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: 10px; }
.composer-buttons { display: flex; align-items: center; gap: 10px; }
.composer-hint { color: #64748b; font-size: 12px; }

/* Chat / Agent 切换按钮 */
.mode-toggle {
  display: flex;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(50, 109, 233, 0.25);
}
.toggle-btn {
  padding: 6px 14px;
  border: none;
  background: transparent;
  color: #64748b;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.toggle-btn.active {
  background: linear-gradient(135deg, #337cf6, #31c3d0);
  color: #fff;
}
.toggle-btn:not(.active):hover {
  background: rgba(50, 109, 233, 0.08);
  color: #2855d9;
}

/* 响应式 */
@media (max-width: 1200px) {
  .chat-shell { grid-template-columns: 280px minmax(0, 1fr); gap: 16px; padding: 16px; }
  .portrait-ring { width: 75px; height: 75px; }
  .profile-copy h2 { font-size: 20px; }
  .chat-title { font-size: 24px; }
  .capability-item { padding: 16px 14px; }
}

@media (max-width: 900px) {
  .chat-shell { grid-template-columns: 1fr; height: 100%; min-height: 0; padding: 10px; }
  .profile-card { display: none; }
  .chat-card { height: 100%; min-height: 0; padding: 16px; }
  .chat-header { margin-bottom: 12px; }
  .chat-title { font-size: 22px; }
  .chat-header p { font-size: 13px; }
  .suggestion-list { display: grid; grid-template-columns: 1fr; gap: 8px; max-height: 156px; overflow-y: auto; }
  .suggestion-chip { width: 100%; text-align: left; white-space: normal; line-height: 1.45; }
}

@media (max-width: 600px) {
  .chat-card { padding: 14px 12px; border-radius: 18px; }
  .chat-header { flex-direction: column; align-items: flex-start; gap: 10px; }
  .chat-title { font-size: 18px; }
  .composer-actions { flex-direction: column; align-items: flex-start; }
  .composer-buttons { width: 100%; justify-content: stretch; flex-wrap: wrap; }
  .composer-buttons .el-button { flex: 1; margin-left: 0 !important; }
  .bubble { max-width: 100%; font-size: 13px; }
  .bubble-avatar { width: 32px; height: 32px; margin-right: 8px; }
  .mode-toggle { flex-shrink: 0; }
}
</style>
