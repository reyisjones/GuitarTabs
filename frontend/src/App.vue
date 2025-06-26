<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
import { onMounted } from 'vue';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

// Check authentication status on app mount
onMounted(async () => {
  if (authStore.isAuthenticated) {
    // Fetch user profile if authenticated
    await authStore.fetchUserProfile();
  }
});

const handleLogout = () => {
  authStore.logout();
}
</script>

<template>
  <header>
    <img alt="Guitar logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />

    <div class="wrapper">
      <h1>Guitar Tabs Player</h1>

      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/tabs">Tab Player</RouterLink>
        <RouterLink to="/tuner">Guitar Tuner</RouterLink>
        <RouterLink to="/about">About</RouterLink>
        
        <!-- Authentication Links -->
        <template v-if="authStore.isAuthenticated">
          <span class="user-greeting">Welcome, {{ authStore.user?.username }}</span>
          <a href="#" @click.prevent="handleLogout">Logout</a>
        </template>
        <template v-else>
          <RouterLink to="/auth">Login / Register</RouterLink>
        </template>
      </nav>
    </div>
  </header>

  <RouterView />
</template>

<style scoped>
header {
  line-height: 1.5;
  max-height: 100vh;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

nav {
  width: 100%;
  font-size: 12px;
  text-align: center;
  margin-top: 2rem;
}

nav a.router-link-exact-active {
  color: var(--color-text);
}

nav a.router-link-exact-active:hover {
  background-color: transparent;
}

nav a {
  display: inline-block;
  padding: 0 1rem;
  border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
  border: 0;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }

  nav {
    text-align: left;
    margin-left: -1rem;
    font-size: 1rem;

    padding: 1rem 0;
    margin-top: 1rem;
  }
}
</style>
