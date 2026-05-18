import apiClient from './client'

/**
 * 生成执行计划
 * @param {{ userId: number, command: string }} payload
 */
export function planTaskApi(payload) {
  return apiClient.post('/agent/tasks/plan', payload)
}

/**
 * 获取用户历史任务列表
 * @param {number} userId
 */
export function listTaskHistoryApi(userId) {
  return apiClient.get(`/agent/tasks/history/${userId}`)
}

/**
 * 获取任务详情
 * @param {number} taskId
 */
export function getTaskApi(taskId) {
  return apiClient.get(`/agent/tasks/${taskId}`)
}

/**
 * 审批并执行任务
 * @param {number} taskId
 * @param {{ userId: number, remark: string }} payload
 */
export function approveAndExecuteApi(taskId, payload) {
  return apiClient.post(`/agent/tasks/${taskId}/approve-execute`, payload)
}

/**
 * 取消任务
 * @param {number} taskId
 * @param {{ userId: number, remark: string }} payload
 */
export function cancelTaskApi(taskId, payload) {
  return apiClient.post(`/agent/tasks/${taskId}/cancel`, payload)
}

/**
 * 删除任务
 * @param {number} taskId
 * @param {{ userId: number }} payload
 */
export function deleteTaskApi(taskId, payload) {
  return apiClient.post(`/agent/tasks/${taskId}/delete`, payload)
}
