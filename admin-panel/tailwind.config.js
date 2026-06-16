/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        armyGreen: '#4B5320',
        saffron: '#FF9933',
      }
    },
  },
  plugins: [],
}
