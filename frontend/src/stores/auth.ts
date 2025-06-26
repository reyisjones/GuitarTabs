import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export interface User {
  id: string;
  username: string;
  email?: string;
}

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);
  const loading = ref(false);
  
  // Initialize from localStorage if available
  const initializeFromStorage = () => {
    const storedToken = localStorage.getItem('auth_token');
    const storedUser = localStorage.getItem('user');
    
    if (storedToken) {
      token.value = storedToken;
    }
    
    if (storedUser) {
      try {
        user.value = JSON.parse(storedUser);
      } catch (e) {
        // Invalid JSON, clear user
        localStorage.removeItem('user');
      }
    }
  };
  
  // Initialize on store creation
  initializeFromStorage();
  
  // Getters
  const isAuthenticated = computed(() => !!token.value);
  
  // Actions
  const setUser = (userData: User | null) => {
    user.value = userData;
    
    if (userData) {
      localStorage.setItem('user', JSON.stringify(userData));
    } else {
      localStorage.removeItem('user');
    }
  };
  
  const setToken = (newToken: string | null) => {
    token.value = newToken;
    
    if (newToken) {
      localStorage.setItem('auth_token', newToken);
    } else {
      localStorage.removeItem('auth_token');
    }
  };
  
  const login = async (username: string, password: string) => {
    loading.value = true;
    
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Login failed');
      }
      
      const data = await response.json();
      
      // Update state
      setUser({
        id: data.user_id,
        username: data.username
      });
      setToken(data.access_token);
      
      return { success: true };
    } catch (error: any) {
      return {
        success: false,
        error: error.message || 'An error occurred during login'
      };
    } finally {
      loading.value = false;
    }
  };
  
  const register = async (username: string, password: string, email?: string) => {
    loading.value = true;
    
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/auth/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password, email }),
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Registration failed');
      }
      
      const data = await response.json();
      
      // Update state
      setUser({
        id: data.user_id,
        username: data.username
      });
      setToken(data.access_token);
      
      return { success: true };
    } catch (error: any) {
      return {
        success: false,
        error: error.message || 'An error occurred during registration'
      };
    } finally {
      loading.value = false;
    }
  };
  
  const logout = () => {
    setUser(null);
    setToken(null);
  };
  
  const fetchUserProfile = async () => {
    if (!token.value) return null;
    
    loading.value = true;
    
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/auth/user`, {
        headers: {
          'Authorization': `Bearer ${token.value}`,
        },
      });
      
      if (!response.ok) {
        if (response.status === 401) {
          // Token expired or invalid
          logout();
        }
        throw new Error('Failed to fetch user profile');
      }
      
      const userData = await response.json();
      setUser({
        id: userData.user_id,
        username: userData.username,
        email: userData.email
      });
      
      return userData;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      return null;
    } finally {
      loading.value = false;
    }
  };
  
  return {
    user,
    token,
    loading,
    isAuthenticated,
    login,
    register,
    logout,
    fetchUserProfile
  };
});
