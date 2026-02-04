function applyBrandSettings() {
    const savedLogoHeight = localStorage.getItem('logoHeight');
    if (savedLogoHeight) {
        document.documentElement.style.setProperty('--logo-height', `${savedLogoHeight}px`);
    }

    const savedSiteTitle = localStorage.getItem('siteTitle');
    if (savedSiteTitle) {
        const titleEl = document.querySelector('.logo h1');
        if (titleEl) {
            titleEl.textContent = savedSiteTitle;
        }
    }
}

applyBrandSettings();

const defaultVideos = [
    {
        id: 1,
        title: "Learn JavaScript in 2024 - Complete Beginner's Guide",
        channel: "Code Academy",
        views: "1.2M views",
        date: "2 weeks ago",
        duration: "45:32",
        thumbnail: "https://images.unsplash.com/photo-1516116216624-53e697fedbea?w=640&h=360&fit=crop",
        category: "education",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Master JavaScript from scratch with this comprehensive tutorial. Perfect for beginners who want to learn web development."
    },
    {
        id: 2,
        title: "Top 10 Gaming Moments of 2024",
        channel: "GameSpot",
        views: "3.5M views",
        date: "1 day ago",
        duration: "15:24",
        thumbnail: "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=640&h=360&fit=crop",
        category: "gaming",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Check out the most epic gaming moments from this year. From speedruns to incredible plays!"
    },
    {
        id: 3,
        title: "Relaxing Piano Music for Study and Work",
        channel: "Peaceful Melodies",
        views: "5.8M views",
        date: "3 months ago",
        duration: "2:15:00",
        thumbnail: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=640&h=360&fit=crop",
        category: "music",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Beautiful piano music to help you focus and relax. Perfect background music for studying or working."
    },
    {
        id: 4,
        title: "iPhone 16 Pro Review - Is It Worth It?",
        channel: "Tech Reviews Daily",
        views: "2.1M views",
        date: "5 days ago",
        duration: "18:45",
        thumbnail: "https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=640&h=360&fit=crop",
        category: "tech",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "In-depth review of the latest iPhone 16 Pro. We cover design, performance, camera quality, and more."
    },
    {
        id: 5,
        title: "Stand-Up Comedy Special 2024",
        channel: "Comedy Central",
        views: "4.2M views",
        date: "1 week ago",
        duration: "52:18",
        thumbnail: "https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=640&h=360&fit=crop",
        category: "entertainment",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Hilarious stand-up comedy special featuring the best comedians of 2024. Get ready to laugh!"
    },
    {
        id: 6,
        title: "How to Build a PC in 2024 - Step by Step",
        channel: "Tech Builder",
        views: "890K views",
        date: "2 weeks ago",
        duration: "32:15",
        thumbnail: "https://images.unsplash.com/photo-1587202372634-32705e3bf49c?w=640&h=360&fit=crop",
        category: "tech",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Complete guide to building your own gaming PC. We cover all components and assembly process."
    },
    {
        id: 7,
        title: "Epic Fortnite Victory Royale Compilation",
        channel: "Pro Gamers",
        views: "1.5M views",
        date: "3 days ago",
        duration: "12:30",
        thumbnail: "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=640&h=360&fit=crop",
        category: "gaming",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Watch the most insane Victory Royales and clutch moments in Fortnite. Amazing gameplay!"
    },
    {
        id: 8,
        title: "Learn Python for Data Science",
        channel: "Data Science Academy",
        views: "2.8M views",
        date: "1 month ago",
        duration: "1:15:42",
        thumbnail: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=640&h=360&fit=crop",
        category: "education",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Master Python programming for data science and machine learning. Includes practical examples."
    },
    {
        id: 9,
        title: "Best EDM Mix 2024 - Festival Vibes",
        channel: "EDM Nation",
        views: "6.2M views",
        date: "2 months ago",
        duration: "1:45:00",
        thumbnail: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=640&h=360&fit=crop",
        category: "music",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "The ultimate EDM mix featuring the hottest tracks of 2024. Perfect for parties and workouts!"
    },
    {
        id: 10,
        title: "Movie Trailers Mashup 2024",
        channel: "Cinema Hub",
        views: "3.9M views",
        date: "4 days ago",
        duration: "22:10",
        thumbnail: "https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=640&h=360&fit=crop",
        category: "entertainment",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "All the best movie trailers from 2024 in one epic mashup. Don't miss these upcoming releases!"
    },
    {
        id: 11,
        title: "AI and Machine Learning Explained",
        channel: "Tech Explained",
        views: "1.7M views",
        date: "1 week ago",
        duration: "28:55",
        thumbnail: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=640&h=360&fit=crop",
        category: "tech",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Understanding artificial intelligence and machine learning in simple terms. Great for beginners!"
    },
    {
        id: 12,
        title: "Minecraft Survival Series - Episode 1",
        channel: "Minecraft Masters",
        views: "2.3M views",
        date: "6 days ago",
        duration: "35:20",
        thumbnail: "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?w=640&h=360&fit=crop",
        category: "gaming",
        videoUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        description: "Join us on an epic Minecraft survival adventure. Building, exploring, and surviving!"
    }
];

let videos = [];

let currentCategory = 'all';
let searchQuery = '';
let currentVideo = null;
let watchTimeInterval = null;
let currentWatchTime = 0;

function getWatchHistory() {
    const history = localStorage.getItem('watchHistory');
    return history ? JSON.parse(history) : {};
}

function saveWatchTime(videoId, time) {
    const history = getWatchHistory();
    history[videoId] = {
        time: time,
        savedAt: new Date().toISOString()
    };
    localStorage.setItem('watchHistory', JSON.stringify(history));
}

function getSavedWatchTime(videoId) {
    const history = getWatchHistory();
    return history[videoId] ? history[videoId].time : 0;
}

function formatTime(seconds) {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    if (hrs > 0) {
        return `${hrs}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${mins}:${secs.toString().padStart(2, '0')}`;
}

function renderVideos(videosToRender) {
    const videoGrid = document.getElementById('videoGrid');
    videoGrid.innerHTML = '';

    videosToRender.forEach(video => {
        const videoCard = document.createElement('div');
        videoCard.className = 'video-card';
        videoCard.onclick = () => openModal(video);

        const savedTime = getSavedWatchTime(video.id);
        const savedBadge = savedTime > 0 ? `<span class="saved-time-badge">Saved at ${formatTime(savedTime)}</span>` : '';

        videoCard.innerHTML = `
            <div class="video-thumbnail">
                <img src="${video.thumbnail}" alt="${video.title}">
                <span class="video-duration">${video.duration}</span>
                ${savedBadge}
            </div>
            <div class="video-info">
                <h3 class="video-title">${video.title}</h3>
                <p class="video-channel">${video.channel}</p>
                <div class="video-meta">
                    <span>${video.views}</span>
                    <span>•</span>
                    <span>${video.date}</span>
                </div>
                <span class="category-badge">${video.category}</span>
            </div>
        `;

        videoGrid.appendChild(videoCard);
    });
}

function filterVideos() {
    let filteredVideos = videos;

    if (currentCategory !== 'all') {
        filteredVideos = filteredVideos.filter(video => video.category === currentCategory);
    }

    if (searchQuery) {
        filteredVideos = filteredVideos.filter(video =>
            video.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            video.channel.toLowerCase().includes(searchQuery.toLowerCase())
        );
    }

    renderVideos(filteredVideos);
}

function openModal(video) {
    currentVideo = video;
    const modal = document.getElementById('videoModal');
    const videoPlayer = document.getElementById('videoPlayer');
    const modalTitle = document.getElementById('modalTitle');
    const modalChannel = document.getElementById('modalChannel');
    const modalViews = document.getElementById('modalViews');
    const modalDate = document.getElementById('modalDate');
    const modalDescription = document.getElementById('modalDescription');
    const watchTimeDisplay = document.getElementById('watchTimeDisplay');
    const saveWatchTimeBtn = document.getElementById('saveWatchTimeBtn');

    const savedTime = getSavedWatchTime(video.id);
    currentWatchTime = savedTime;

    videoPlayer.src = video.videoUrl;
    modalTitle.textContent = video.title;
    modalChannel.textContent = video.channel;
    modalViews.textContent = video.views;
    modalDate.textContent = video.date;
    modalDescription.textContent = video.description;
    watchTimeDisplay.textContent = formatTime(currentWatchTime);

    if (savedTime > 0) {
        saveWatchTimeBtn.textContent = `Resume from ${formatTime(savedTime)}`;
    } else {
        saveWatchTimeBtn.textContent = 'Save Watch Time';
    }

    watchTimeInterval = setInterval(() => {
        currentWatchTime++;
        watchTimeDisplay.textContent = formatTime(currentWatchTime);
    }, 1000);

    modal.style.display = 'block';
}

function closeModal() {
    const modal = document.getElementById('videoModal');
    const videoPlayer = document.getElementById('videoPlayer');
    modal.style.display = 'none';
    videoPlayer.src = '';

    if (watchTimeInterval) {
        clearInterval(watchTimeInterval);
        watchTimeInterval = null;
    }

    if (currentVideo) {
        saveWatchTime(currentVideo.id, currentWatchTime);
        currentVideo = null;
    }
}

async function loadVideosFromApi() {
    try {
        const response = await fetch('/api/videos');
        if (!response.ok) throw new Error('Failed to load videos');
        const data = await response.json();
        videos = Array.isArray(data) ? data : [];
    } catch (error) {
        console.error(error);
        videos = defaultVideos;
    }
}

document.addEventListener('DOMContentLoaded', async () => {
    await loadVideosFromApi();
    renderCategories();
    renderVideos(videos);

    const searchInput = document.getElementById('searchInput');
    const searchBtn = document.getElementById('searchBtn');

    searchBtn.addEventListener('click', () => {
        searchQuery = searchInput.value;
        filterVideos();
    });

    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            searchQuery = searchInput.value;
            filterVideos();
        }
    });

    searchInput.addEventListener('input', (e) => {
        if (e.target.value === '') {
            searchQuery = '';
            filterVideos();
        }
    });

    const closeBtn = document.querySelector('.close');
    closeBtn.addEventListener('click', closeModal);

    window.addEventListener('click', (e) => {
        const modal = document.getElementById('videoModal');
        if (e.target === modal) {
            closeModal();
        }
    });
});

function renderCategories() {
    const categories = ['all', ...new Set(videos.map(video => video.category))];
    const filtersContainer = document.querySelector('.filters');
    filtersContainer.innerHTML = '';
    
    categories.forEach(category => {
        const button = document.createElement('button');
        button.className = 'filter-btn';
        button.dataset.category = category;
        button.textContent = category.charAt(0).toUpperCase() + category.slice(1);
        if (category === currentCategory) {
            button.classList.add('active');
        }
        button.addEventListener('click', (e) => {
            currentCategory = e.currentTarget.dataset.category;
            document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
            e.currentTarget.classList.add('active');
            filterVideos();
        });
        filtersContainer.appendChild(button);
    });
}
