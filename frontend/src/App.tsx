import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

interface WeatherForecast {
  date: string
  temperatureC: number
  temperatureF: number
  summary: string
}

const API_BASE_URL = 'http://localhost:5000/api'

function App() {
  const [weatherData, setWeatherData] = useState<WeatherForecast[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetchWeather = async () => {
    setLoading(true)
    setError(null)
    try {
      const response = await axios.get<WeatherForecast[]>(`${API_BASE_URL}/weatherforecast`)
      setWeatherData(response.data)
    } catch (err) {
      setError('Không thể kết nối đến API. Đảm bảo backend đang chạy tại http://localhost:5000')
      console.error('Error fetching weather data:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchWeather()
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <h1>Genshin Project</h1>
        <p>React + .NET Core Full Stack Application</p>
      </header>

      <main className="App-main">
        <button onClick={fetchWeather} disabled={loading}>
          {loading ? 'Đang tải...' : 'Làm mới dữ liệu'}
        </button>

        {error && (
          <div className="error-message">
            {error}
          </div>
        )}

        {weatherData.length > 0 && (
          <div className="weather-container">
            <h2>Weather Forecast</h2>
            <div className="weather-grid">
              {weatherData.map((forecast, index) => (
                <div key={index} className="weather-card">
                  <h3>{forecast.date}</h3>
                  <p className="temperature">{forecast.temperatureC}°C / {forecast.temperatureF}°F</p>
                  <p className="summary">{forecast.summary}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  )
}

export default App

