import { useAuthStore } from '@/stores/auth';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

interface ApiOptions {
  method?: string;
  body?: any;
  headers?: Record<string, string>;
  requiresAuth?: boolean;
}

interface ApiResponse<T> {
  data?: T;
  error?: string;
  status: number;
  ok: boolean;
}

/**
 * Helper function for making API calls with authentication
 * 
 * @param endpoint - API endpoint (without base URL)
 * @param options - Request options
 * @returns Promise with structured API response
 */
export async function api<T = any>(
  endpoint: string, 
  options: ApiOptions = {}
): Promise<ApiResponse<T>> {
  const { 
    method = 'GET',
    body,
    headers = {},
    requiresAuth = true
  } = options;
  
  const authStore = useAuthStore();
  
  // Build request URL
  const url = `${API_URL}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;
  
  // Build request headers
  const requestHeaders: Record<string, string> = {
    ...headers
  };
  
  // Add Content-Type header for JSON requests
  if (body && typeof body === 'object' && !(body instanceof FormData)) {
    requestHeaders['Content-Type'] = 'application/json';
  }
  
  // Add Authorization header if required
  if (requiresAuth && authStore.token) {
    requestHeaders['Authorization'] = `Bearer ${authStore.token}`;
  }
  
  // Build request options
  const requestOptions: RequestInit = {
    method,
    headers: requestHeaders
  };
  
  // Add request body if present
  if (body) {
    if (body instanceof FormData) {
      requestOptions.body = body;
    } else {
      requestOptions.body = JSON.stringify(body);
    }
  }
  
  try {
    // Make the API request
    const response = await fetch(url, requestOptions);
    
    // Handle 401 Unauthorized (token expired or invalid)
    if (response.status === 401 && requiresAuth) {
      authStore.logout();
      return {
        error: 'Your session has expired. Please login again.',
        status: response.status,
        ok: false
      };
    }
    
    let data;
    let error;
    
    // Parse response data based on content type
    const contentType = response.headers.get('content-type');
    
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
      
      // Extract error message from JSON response if present
      if (!response.ok && data && data.error) {
        error = data.error;
      }
    } else if (!response.ok) {
      // For non-JSON error responses, use status text
      error = response.statusText;
    }
    
    return {
      data: response.ok ? data : undefined,
      error: !response.ok ? error || 'An error occurred' : undefined,
      status: response.status,
      ok: response.ok
    };
  } catch (err) {
    // Handle network errors
    return {
      error: err instanceof Error ? err.message : 'Network error',
      status: 0,
      ok: false
    };
  }
}

/**
 * Shorthand for GET requests
 */
export function get<T = any>(
  endpoint: string, 
  options: Omit<ApiOptions, 'method' | 'body'> = {}
): Promise<ApiResponse<T>> {
  return api<T>(endpoint, { ...options, method: 'GET' });
}

/**
 * Shorthand for POST requests
 */
export function post<T = any>(
  endpoint: string,
  body: any,
  options: Omit<ApiOptions, 'method' | 'body'> = {}
): Promise<ApiResponse<T>> {
  return api<T>(endpoint, { ...options, method: 'POST', body });
}

/**
 * Shorthand for PUT requests
 */
export function put<T = any>(
  endpoint: string,
  body: any,
  options: Omit<ApiOptions, 'method' | 'body'> = {}
): Promise<ApiResponse<T>> {
  return api<T>(endpoint, { ...options, method: 'PUT', body });
}

/**
 * Shorthand for DELETE requests
 */
export function del<T = any>(
  endpoint: string,
  options: Omit<ApiOptions, 'method'> = {}
): Promise<ApiResponse<T>> {
  return api<T>(endpoint, { ...options, method: 'DELETE' });
}
