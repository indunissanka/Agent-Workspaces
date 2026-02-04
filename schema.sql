CREATE TABLE IF NOT EXISTS videos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    channel TEXT NOT NULL,
    views TEXT NOT NULL,
    date TEXT NOT NULL,
    duration TEXT NOT NULL,
    thumbnail TEXT,
    category TEXT NOT NULL,
    video_url TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data from the defaultVideos array in script.js
INSERT OR IGNORE INTO videos (id, title, channel, views, date, duration, thumbnail, category, video_url, description) VALUES
(1, "Learn JavaScript in 2024 - Complete Beginner's Guide", "Code Academy", "1.2M views", "2 weeks ago", "45:32", "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=640&h=360&fit=crop", "education", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Master JavaScript from scratch with this comprehensive tutorial. Perfect for beginners who want to learn web development."),
(2, "Top 10 Gaming Moments of 2024", "GameSpot", "3.5M views", "1 day ago", "15:24", "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=640&h=360&fit=crop", "gaming", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Check out the most epic gaming moments from this year. From speedruns to incredible plays!"),
(3, "Relaxing Piano Music for Study and Work", "Peaceful Melodies", "5.8M views", "3 months ago", "2:15:00", "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=640&h=360&fit=crop", "music", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Beautiful piano music to help you focus and relax. Perfect background music for studying or working.");
