<script setup lang="ts">
import { ref } from 'vue';

const props = defineProps({
  accept: {
    type: String,
    default: '.gp,.gpx,.gp5,.musicxml'
  },
  maxSize: {
    type: Number,
    default: 10 * 1024 * 1024  // 10MB default
  }
});

const emit = defineEmits(['file-selected', 'upload-start', 'upload-success', 'upload-error']);

const fileInput = ref<HTMLInputElement | null>(null);
const dragActive = ref(false);
const isUploading = ref(false);
const uploadProgress = ref(0);
const errorMessage = ref('');

// Allowed file types
const allowedFileTypes = props.accept.split(',');

// Handle file selection via input
function handleFileSelect(event: Event) {
  const target = event.target as HTMLInputElement;
  if (target && target.files && target.files.length > 0) {
    processFile(target.files[0]);
  }
}

// Handle file drop
function handleDrop(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
  dragActive.value = false;
  
  if (event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length > 0) {
    processFile(event.dataTransfer.files[0]);
  }
}

// Process the selected file
function processFile(file: File) {
  errorMessage.value = '';
  
  // Check file type
  const fileExtension = `.${file.name.split('.').pop()?.toLowerCase()}`;
  if (!allowedFileTypes.includes(fileExtension) && !allowedFileTypes.includes('*')) {
    errorMessage.value = `Invalid file type. Please select ${props.accept} files.`;
    return;
  }
  
  // Check file size
  if (file.size > props.maxSize) {
    const maxSizeMb = props.maxSize / (1024 * 1024);
    errorMessage.value = `File size exceeds the ${maxSizeMb}MB limit.`;
    return;
  }
  
  // Emit file selected event
  emit('file-selected', file);
  
  // If needed, upload the file
  uploadFile(file);
}

// Upload file to server
async function uploadFile(file: File) {
  isUploading.value = true;
  uploadProgress.value = 0;
  
  // Create form data for the upload
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    // Emit upload start event
    emit('upload-start', file);
    
    // Upload using fetch with progress tracking
    const xhr = new XMLHttpRequest();
    
    // Track progress
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        uploadProgress.value = Math.round((e.loaded / e.total) * 100);
      }
    });
      // Get authentication token from localStorage
    const token = localStorage.getItem('auth_token');
    
    if (!token) {
      throw new Error('Authentication required. Please login to upload files.');
    }
    
    // Create a Promise to handle the response
    const uploadPromise = new Promise<any>((resolve, reject) => {
      xhr.addEventListener('load', () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          try {
            const response = JSON.parse(xhr.responseText);
            resolve(response);
          } catch (error) {
            reject(new Error('Invalid response format'));
          }
        } else if (xhr.status === 401) {
          // Handle authentication errors
          reject(new Error('Authentication expired. Please login again.'));
        } else {
          reject(new Error(`HTTP error ${xhr.status}: ${xhr.statusText}`));
        }
      });
      
      xhr.addEventListener('error', () => reject(new Error('Network error')));
      xhr.addEventListener('abort', () => reject(new Error('Upload aborted')));
    });
    
    // Start the upload
    const apiUrl = import.meta.env.VITE_API_URL || '';
    xhr.open('POST', `${apiUrl}/api/tabs`);
    xhr.setRequestHeader('Authorization', `Bearer ${token}`);
    xhr.send(formData);
    
    // Wait for response
    const response = await uploadPromise;
    
    // Emit success event
    emit('upload-success', response);
  } catch (error) {
    errorMessage.value = error instanceof Error ? error.message : 'Unknown error occurred';
    emit('upload-error', error);
  } finally {
    isUploading.value = false;
  }
}

// Handle drag events
function handleDragOver(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
  dragActive.value = true;
}

function handleDragLeave(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
  dragActive.value = false;
}

// Programmatically trigger file input click
function openFileSelector() {
  if (fileInput.value) {
    fileInput.value.click();
  }
}
</script>

<template>
  <div class="tab-file-uploader">
    <div 
      :class="['drop-area', { 'drag-active': dragActive, 'is-uploading': isUploading }]"
      @dragover="handleDragOver"
      @dragleave="handleDragLeave"
      @drop="handleDrop"
      @click="openFileSelector"
    >
      <input 
        type="file"
        ref="fileInput"
        :accept="accept"
        @change="handleFileSelect"
        style="display: none"
      />
      
      <div v-if="!isUploading" class="upload-prompt">
        <span class="icon">📄</span>
        <p>Drag and drop your tablature file or click to browse</p>
        <p class="file-types">Accepted formats: {{ accept }}</p>
      </div>
      
      <div v-else class="upload-status">
        <div class="progress-bar">
          <div class="progress" :style="{ width: `${uploadProgress}%` }"></div>
        </div>
        <p>Uploading... {{ uploadProgress }}%</p>
      </div>
    </div>
    
    <div v-if="errorMessage" class="error-message">
      {{ errorMessage }}
    </div>
  </div>
</template>

<style scoped>
.tab-file-uploader {
  width: 100%;
  margin-bottom: 20px;
}

.drop-area {
  border: 2px dashed #ccc;
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background-color: #f9f9f9;
}

.drop-area:hover {
  border-color: #4a90e2;
  background-color: #f0f8ff;
}

.drag-active {
  border-color: #4a90e2;
  background-color: #e6f2ff;
}

.is-uploading {
  pointer-events: none;
  opacity: 0.8;
}

.upload-prompt {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.file-types {
  font-size: 14px;
  color: #666;
  margin-top: 5px;
}

.upload-status {
  width: 80%;
  margin: 0 auto;
}

.progress-bar {
  height: 10px;
  background-color: #eee;
  border-radius: 5px;
  overflow: hidden;
  margin-bottom: 10px;
}

.progress {
  height: 100%;
  background-color: #4a90e2;
  transition: width 0.2s ease;
}

.error-message {
  color: #e74c3c;
  margin-top: 10px;
  padding: 10px;
  background-color: #fde2e2;
  border-radius: 4px;
  border-left: 4px solid #e74c3c;
}
</style>
