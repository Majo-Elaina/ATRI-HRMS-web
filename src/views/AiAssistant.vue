<script setup>
import AtriChatPanel from '@/components/ai/AtriChatPanel.vue'
import atriAvatar from '@/assets/images/亚托莉.webp'
</script>

<template>
  <div class="atri-page">
    <AtriChatPanel :avatar="atriAvatar" />
  </div>
</template>

<style scoped>
.atri-page {
  height: calc(100vh - 72px);
  overflow: hidden;
  user-select: text;
}

.atri-page * {
  user-select: text;
}

.atri-page button,
.atri-page .el-button {
  user-select: none;
}

@media (max-width: 768px) {
  .atri-page {
    height: calc(100dvh - 60px);
  }
}

@media (max-width: 480px) {
  .atri-page {
    height: calc(100dvh - 56px);
  }
}
</style>
