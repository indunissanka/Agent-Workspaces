-- Initial schema for videohub_db
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

-- Insert sample data (all 12 videos from frontend)
INSERT OR IGNORE INTO videos (id, title, channel, views, date, duration, thumbnail, category, video_url, description) VALUES
(1, "Learn JavaScript in 2024 - Complete Beginner's Guide", "Code Academy", "1.2M views", "2 weeks ago", "45:32", "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=640&h=360&fit=crop", "education", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Master JavaScript from scratch with this comprehensive tutorial. Perfect for beginners who want to learn web development."),
(2, "Top 10 Gaming Moments of 2024", "GameSpot", "3.5M views", "1 day ago", "15:24", "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=640&h=360&fit=crop", "gaming", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Check out the most epic gaming moments from this year. From speedruns to incredible plays!"),
(3, "Relaxing Piano Music for Study and Work", "Peaceful Melodies", "5.8M views", "3 months ago", "2:15:00", "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=640&h=360&fit=crop", "music", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Beautiful piano music to help you focus and relax. Perfect background music for studying or working."),
(4, "iPhone 16 Pro Review - Is It Worth It?", "Tech Reviews Daily", "2.1M views", "5 days ago", "18:45", "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=640&h=360&fit=crop", "tech", "https://www.youtube.com/embed/dQw4w9WgXcQ", "In-depth review of the latest iPhone 16 Pro. We cover design, performance, camera quality, and more."),
(5, "Stand-Up Comedy Special 2024", "Comedy Central", "4.2M views", "1 week ago", "52:18", "https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=640&h=360&fit=crop", "entertainment", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Hilarious stand-up comedy special featuring the best comedians of 2024. Get ready to laugh!"),
(6, "How to Build a PC in 2024 - Step by Step", "Tech Builder", "890K views", "2 weeks ago", "32:15", "https://images.unsplash.com/photo-1587202372634-32705e3bf49c?w=640&h=360&fit=crop", "tech", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Complete guide to building your own gaming PC. We cover all components and assembly process."),
(7, "Epic Fortnite Victory Royale Compilation", "Pro Gamers", "1.5M views", "3 days ago", "12:30", "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=640&h=360&fit=crop", "gaming", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Watch the most insane Victory Royales and clutch moments in Fortnite. Amazing gameplay!"),
(8, "Learn Python for Data Science", "Data Science Academy", "2.8M views", "1 month ago", "1:15:42", "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=640&h=360&fit=crop", "education", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Master Python programming for data science and machine learning. Includes practical examples."),
(9, "Best EDM Mix 2024 - Festival Vibes", "EDM Nation", "6.2M views", "2 months ago", "1:45:00", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=640&h=360&fit=crop", "music", "https://www.youtube.com/embed/dQw4w9WgXcQ", "The ultimate EDM mix featuring the hottest tracks of 2024. Perfect for parties and workouts!"),
(10, "Movie Trailers Mashup 2024", "Cinema Hub", "3.9M views", "4 days ago", "22:10", "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=640&h=360&fit=crop", "entertainment", "https://www.youtube.com/embed/dQw4w9WgXcQ", "All the best movie trailers from 2024 in one epic mashup. Don't miss these upcoming releases!"),
(11, "AI and Machine Learning Explained", "Tech Explained", "1.7M views", "1 week ago", "28:55", "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=640&h=360&fit=crop", "tech", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Understanding artificial intelligence and machine learning in simple terms. Great for beginners!"),
(12, "Minecraft Survival Series - Episode 1", "Minecraft Masters", "2.3M views", "6 days ago", "35:20", "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=640&h=360&fit=crop", "gaming", "https://www.youtube.com/embed/dQw4w9WgXcQ", "Join us on an epic Minecraft survival adventure. Building, exploring, and surviving!");