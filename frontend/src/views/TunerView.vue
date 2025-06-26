<script setup lang="ts">
import GuitarTuner from '@/components/guitar/GuitarTuner.vue';
</script>

<template>
  <div class="tuner-view">
    <h1>Guitar Tuner</h1>
    <p class="description">
      Use this interactive tuner to tune your guitar to standard tuning (E A D G B E).
      Click on any string to hear the reference pitch.
    </p>
    <div class="tuner-container">
      <GuitarTuner />
    </div>
    
    <div class="instructions">
      <h2>How to tune your guitar:</h2>
      <ol>
        <li>Click on the string you want to tune</li>
        <li>Play the corresponding string on your guitar</li>
        <li>Adjust the tuning pegs until the pitch of your guitar string matches the reference tone</li>
        <li>Continue with the next string</li>
      </ol>
      
      <div class="tips">
        <h3>Tuning Tips:</h3>
        <ul>
          <li>Start with the low E string (thickest) and work your way to the high E (thinnest)</li>
          <li>If the string is too low, tighten the tuning peg</li>
          <li>If the string is too high, loosen the tuning peg</li>
          <li>Make small adjustments to avoid breaking strings</li>
          <li>A string that is in tune will have the same pitch as the reference tone</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tuner-view {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.description {
  text-align: center;
  margin-bottom: 30px;
  color: #666;
  font-size: 1.1rem;
}

.tuner-container {
  margin-bottom: 40px;
}

.instructions {
  background-color: #f9f9f9;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.instructions h2 {
  margin-top: 0;
  color: #333;
}

.instructions ol, .instructions ul {
  padding-left: 20px;
}

.instructions li {
  margin-bottom: 10px;
  line-height: 1.5;
}

.tips {
  margin-top: 25px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.tips h3 {
  color: #333;
}
</style>
