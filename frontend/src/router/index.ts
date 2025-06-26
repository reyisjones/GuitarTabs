import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import { authGuard, unauthenticatedGuard } from './guards'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/tabs',
      name: 'tabs',
      component: () => import('../views/TabsView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/tuner',
      name: 'tuner',
      component: () => import('../views/TunerView.vue'),
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/auth',
      name: 'auth',
      component: () => import('../views/AuthView.vue'),
      meta: { guestOnly: true }
    }
  ],
})



// Navigation Guards - Apply the authentication guard
router.beforeEach(authGuard);

// Guest-only routes guard
router.beforeEach((to, from, next) => {
  // Check if route is guest-only
  const guestOnly = to.matched.some(record => record.meta.guestOnly);
  
  // Get authentication status from localStorage
  const isAuthenticated = !!localStorage.getItem('auth_token');
  
  if (guestOnly && isAuthenticated) {
    // Redirect to home if trying to access guest-only route while authenticated
    next({ name: 'home' });
  } else {
    // Continue to route
    next();
  }
});

export default router
