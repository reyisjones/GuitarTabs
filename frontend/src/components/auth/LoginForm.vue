<template>
  <div class="login-form">
    <div v-if="error" class="error-message">{{ error }}</div>
    
    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="username">Username</label>
        <input 
          type="text" 
          id="username" 
          v-model="username" 
          required 
          placeholder="Enter your username"
        />
      </div>
      
      <div class="form-group">
        <label for="password">Password</label>
        <input 
          type="password" 
          id="password" 
          v-model="password" 
          required
          placeholder="Enter your password" 
        />
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn-primary" :disabled="isLoading">
          {{ isLoading ? 'Logging in...' : 'Login' }}
        </button>
        <button type="button" class="btn-link" @click="$emit('switch-mode')">
          Need an account? Register
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

// State
const username = ref('');
const password = ref('');
const error = ref('');
const isLoading = ref(false);

import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

// Props and Emits
const emit = defineEmits(['login-success', 'switch-mode']);

const router = useRouter();
const authStore = useAuthStore();

// Handle login form submission
const handleSubmit = async () => {
  error.value = '';
  isLoading.value = true;
  
  try {
    const result = await authStore.login(username.value, password.value);
    
    if (result.success) {
      // Reset form
      username.value = '';
      password.value = '';
      
      // Emit success event with user data
      emit('login-success', authStore.user);
      router.push('/tabs');
    } else {
      error.value = result.error || 'Login failed. Please check your credentials.';
    }
  } catch (err) {
    error.value = 'An unexpected error occurred. Please try again.';
    console.error(err);
  } finally {
    isLoading.value = false;
  }
};
</script>

<style scoped>
.login-form {
  max-width: 400px;
  margin: 0 auto;
  padding: 2rem;
  border-radius: 8px;
  background-color: var(--color-background-soft);
}

.error-message {
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
  color: #721c24;
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 4px;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: bold;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 1rem;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-primary {
  padding: 0.75rem 1.5rem;
  background-color: var(--color-primary);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
}

.btn-primary:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.btn-link {
  background: none;
  border: none;
  color: var(--color-primary);
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0;
}
</style>
