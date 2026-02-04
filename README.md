# YouTube Video Listing Site

A modern, responsive YouTube-style video listing website built with HTML, CSS, and JavaScript.

## Features

- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Video Grid Layout**: Clean card-based layout displaying video thumbnails
- **Category Filtering**: Filter videos by category (All, Music, Gaming, Education, Technology, Entertainment)
- **Search Functionality**: Search videos by title or channel name
- **Video Modal**: Click any video to view it in a modal player
- **Modern UI**: Dark theme inspired by YouTube's interface

## Files

- `index.html` - Main HTML structure
- `styles.css` - Responsive CSS styling
- `script.js` - JavaScript for interactivity and data management

## How to Use

1. Open `index.html` in your web browser
2. Browse through the video grid
3. Use category filters to narrow down videos
4. Search for specific videos using the search bar
5. Click on any video card to watch it in the modal player

## Customization

You can easily customize the site by:
- Adding more videos to the `videos` array in `script.js`
- Modifying colors in `styles.css`
- Adding new categories to the filter buttons
- Replacing placeholder video URLs with actual YouTube embed links

## Deployment to Cloudflare

This app includes a Cloudflare Workers backend with D1 database for persistent video storage.

### Quick Deployment
Run the automated installation script:
```bash
chmod +x install-cloudflare.sh && ./install-cloudflare.sh
```

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md) and [AUTOMATED_INSTALL.md](AUTOMATED_INSTALL.md).

### Features
- **Cloudflare Workers**: Serverless backend API
- **D1 Database**: SQLite-based database for video storage
- **Assets Binding**: Static files served from Worker
- **One-command Installation**: Fully automated deployment

Enjoy your video listing site!
