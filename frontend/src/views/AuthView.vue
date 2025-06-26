<template>
  <div class="auth-view">
    <div class="container">
      <h1>{{ isLogin ? 'Welcome Back' : 'Create an Account' }}</h1>
      
      <component 
        :is="isLogin ? LoginForm : RegisterForm"
        @login-success="handleAuthSuccess"
        @register-success="handleAuthSuccess"
        @switch-mode="toggleMode"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import LoginForm from '@/components/auth/LoginForm.vue';
import RegisterForm from '@/components/auth/RegisterForm.vue';

const router = useRouter();
const isLogin = ref(true);

// Toggle between login and register
const toggleMode = () => {
  isLogin.value = !isLogin.value;
};

// Handle successful authentication
const handleAuthSuccess = (userData: any) => {
  // Redirect to home page or a protected page
  router.push('/tabs');
};
</script>

<style scoped>
.auth-view {
  padding: 2rem 0;
  min-height: calc(100vh - 60px);
  display: flex;
  align-items: center;
}

.container {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
}
</style>
