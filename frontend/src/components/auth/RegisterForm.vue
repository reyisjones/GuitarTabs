<template>
  <div class="register-form">
    <div v-if="error" class="error-message">{{ error }}</div>
    
    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="username">Username</label>
        <input 
          type="text" 
          id="username" 
          v-model="username" 
          required 
          placeholder="Choose a username"
        />
      </div>

      <div class="form-group">
        <label for="email">Email (optional)</label>
        <input 
          type="email" 
          id="email" 
          v-model="email" 
          placeholder="Enter your email address"
        />
      </div>
      
      <div class="form-group">
        <label for="password">Password</label>
        <input 
          type="password" 
          id="password" 
          v-model="password" 
          required
          placeholder="Choose a password"
          minlength="8" 
        />
      </div>

      <div class="form-group">
        <label for="confirmPassword">Confirm Password</label>
        <input 
          type="password" 
          id="confirmPassword" 
          v-model="confirmPassword" 
          required
          placeholder="Confirm your password"
          minlength="8" 
        />
        <div v-if="passwordMismatch" class="validation-error">
          Passwords do not match
        </div>
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn-primary" :disabled="isLoading || passwordMismatch">
          {{ isLoading ? 'Registering...' : 'Register' }}
        </button>
        <button type="button" class="btn-link" @click="$emit('switch-mode')">
          Already have an account? Login
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

// State
const username = ref('');
const email = ref('');
const password = ref('');
const confirmPassword = ref('');
const error = ref('');
const isLoading = ref(false);

// Computed properties
const passwordMismatch = computed((): boolean => {
  // Explicitly return a boolean value
  return Boolean(confirmPassword.value && password.value !== confirmPassword.value);
});

import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

// Props and Emits
const emit = defineEmits(['register-success', 'switch-mode']);

const router = useRouter();
const authStore = useAuthStore();

// Methods
const handleSubmit = async () => {
  // Validate passwords match
  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match';
    return;
  }
  
  error.value = '';
  isLoading.value = true;
  
  try {
    const result = await authStore.register(
      username.value,
      password.value,
      email.value || undefined
    );
    
    if (result.success) {
      // Reset form
      username.value = '';
      email.value = '';
      password.value = '';
      confirmPassword.value = '';
      
      // Emit success event with user data
      emit('register-success', authStore.user);
      router.push('/tabs');
    } else {
      error.value = result.error || 'Registration failed';
    }
    
  } catch (err: any) {
    error.value = err.message || 'An error occurred during registration';
  } finally {
    isLoading.value = false;
  }
};
</script>

<style scoped>
.register-form {
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

.validation-error {
  color: #721c24;
  font-size: 0.875rem;
  margin-top: 0.25rem;
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
