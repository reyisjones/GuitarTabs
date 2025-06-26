<script setup lang="ts">
import { ref, onMounted } from 'vue';
import TabPlayer from '@/components/guitar/TabPlayer.vue';
import TabFileUploader from '@/components/guitar/TabFileUploader.vue';

const tabFile = ref<string>('');
const tabFilesList = ref<any[]>([]);
const selectedTabId = ref<string>('');
const loadingTabs = ref(false);
const errorMessage = ref('');

// API URL (should be from environment variables in production)
const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000';

// Fetch available tabs on mount
onMounted(async () => {
  await fetchTabs();
});

// Import the API utilities
import { get } from '@/utils/api';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

// Fetch available tabs from the API
async function fetchTabs() {
  loadingTabs.value = true;
  errorMessage.value = '';

  try {
    const result = await get('/api/tabs', { 
      requiresAuth: false // Allow fetching tabs without authentication
    });
    
    if (!result.ok) {
      throw new Error(result.error || 'Failed to fetch tabs');
    }
    
    tabFilesList.value = result.data?.tabs || [];
  } catch (error) {
    console.error('Error fetching tabs:', error);
    errorMessage.value = 'Failed to load tabs list. The server may be offline.';
    tabFilesList.value = [];
  } finally {
    loadingTabs.value = false;
  }
}

// Handle tab file selection
async function handleTabUploadSuccess(response: any) {
  // Add the new tab to the list
  tabFilesList.value.push(response);
  
  // Select the newly uploaded tab
  await loadTab(response.id);
  
  // Refresh tabs list
  fetchTabs();
}

// Load a tab file from the server
async function loadTab(tabId: string) {
  if (!tabId) return;
  
  selectedTabId.value = tabId;
  tabFile.value = '';
  errorMessage.value = '';
  
  try {
    const response = await fetch(`${apiBaseUrl}/api/tabs/${tabId}`);
    
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    
    const blob = await response.blob();
    tabFile.value = URL.createObjectURL(blob);
  } catch (error) {
    console.error('Error loading tab:', error);
    errorMessage.value = 'Failed to load the selected tab file.';
  }
}

// Delete a tab from the server
async function deleteTab(tabId: string) {
  if (!tabId) return;
  
  try {
    const response = await fetch(`${apiBaseUrl}/api/tabs/${tabId}`, {
      method: 'DELETE'
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    
    // If the deleted tab was selected, clear the current tab
    if (selectedTabId.value === tabId) {
      selectedTabId.value = '';
      tabFile.value = '';
    }
    
    // Refresh tabs list
    fetchTabs();
  } catch (error) {
    console.error('Error deleting tab:', error);
    errorMessage.value = 'Failed to delete the tab file.';
  }
}
</script>

<template>
  <div class="tab-view">
    <h1>Tab Player</h1>
    
    <div class="tabs-container">
      <!-- Tab File Upload -->
      <div class="tab-upload-section">
        <h2>Upload a Tab File</h2>
        <TabFileUploader 
          accept=".gp,.gpx,.gp5,.musicxml"
          @upload-success="handleTabUploadSuccess"
        />
      </div>
      
      <!-- Available Tabs List -->
      <div class="tab-list-section">
        <h2>Available Tabs</h2>
        
        <div v-if="loadingTabs" class="loading">
          Loading tabs...
        </div>
        
        <div v-else-if="errorMessage" class="error-message">
          {{ errorMessage }}
        </div>
        
        <div v-else-if="tabFilesList.length === 0" class="no-tabs">
          No tab files available. Upload one to get started!
        </div>
        
        <ul v-else class="tabs-list">
          <li 
            v-for="tab in tabFilesList" 
            :key="tab.id"
            :class="{ 'selected': selectedTabId === tab.id }"
          >
            <div class="tab-item" @click="loadTab(tab.id)">
              <span class="tab-name">{{ tab.filename }}</span>
              <span class="tab-date">{{ new Date(tab.date_added).toLocaleDateString() }}</span>
            </div>
            <button class="delete-btn" @click.stop="deleteTab(tab.id)">×</button>
          </li>
        </ul>
      </div>
    </div>
    
    <!-- Tab Player -->
    <div v-if="tabFile" class="tab-player-container">
      <TabPlayer :file="tabFile" />
    </div>
    
    <div v-else class="tab-player-placeholder">
      <p>Select or upload a tab file to view it here.</p>
    </div>
  </div>
</template>

<style scoped>
.tab-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.tabs-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 30px;
}

@media (max-width: 768px) {
  .tabs-container {
    grid-template-columns: 1fr;
  }
}

.tab-upload-section,
.tab-list-section {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.tabs-list {
  list-style: none;
  padding: 0;
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #eee;
  border-radius: 4px;
}

.tabs-list li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 15px;
  border-bottom: 1px solid #eee;
  cursor: pointer;
  transition: background-color 0.2s;
}

.tabs-list li:hover {
  background-color: #f0f0f0;
}

.tabs-list li.selected {
  background-color: #e6f2ff;
}

.tab-item {
  flex: 1;
  display: flex;
  justify-content: space-between;
}

.tab-name {
  font-weight: 500;
}

.tab-date {
  color: #666;
  font-size: 0.9em;
}

.delete-btn {
  background: none;
  border: none;
  color: #e74c3c;
  font-size: 18px;
  cursor: pointer;
  padding: 0 5px;
  opacity: 0.6;
}

.delete-btn:hover {
  opacity: 1;
}

.loading,
.no-tabs,
.error-message {
  padding: 20px;
  text-align: center;
  color: #666;
}

.error-message {
  color: #e74c3c;
}

.tab-player-container {
  margin-top: 20px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.tab-player-placeholder {
  margin-top: 20px;
  padding: 40px;
  text-align: center;
  background-color: #f9f9f9;
  border-radius: 8px;
  border: 2px dashed #ccc;
}
</style>
