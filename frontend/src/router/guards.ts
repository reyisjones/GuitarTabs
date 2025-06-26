import { useAuthStore } from '@/stores/auth';
import type { NavigationGuardNext, RouteLocationNormalized } from 'vue-router';

/**
 * Authentication guard for routes that require login
 * 
 * Usage:
 * 1. Import this guard in router/index.ts
 * 2. Add it to the meta property of routes: { meta: { requiresAuth: true } }
 * 
 * @param to - Route being navigated to
 * @param from - Route being navigated from
 * @param next - Navigation guard callback
 */
export async function authGuard(
  to: RouteLocationNormalized, 
  from: RouteLocationNormalized, 
  next: NavigationGuardNext
) {
  const authStore = useAuthStore();
  
  // Check if route requires authentication
  if (!to.meta.requiresAuth) {
    return next();
  }
  
  // If user is already authenticated
  if (authStore.isAuthenticated) {
    // If we don't have user data yet, try to fetch it
    if (!authStore.user) {
      try {
        await authStore.fetchUserProfile();
      } catch (error) {
        console.error('Failed to fetch user profile:', error);
        // Continue anyway, as we have a valid token
      }
    }
    return next();
  }
  
  // Remember where the user was trying to go for redirect after login
  next({
    name: 'auth',
    query: { redirect: to.fullPath }
  });
}

/**
 * Guard for authentication routes (login/register)
 * Redirects to home if already authenticated
 */
export function unauthenticatedGuard(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  const authStore = useAuthStore();
  
  if (authStore.isAuthenticated) {
    return next({ name: 'home' });
  }
  
  next();
}
