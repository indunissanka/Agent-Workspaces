const jsonResponse = (data, status = 200) => {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'content-type': 'application/json',
    },
  });
};

const errorResponse = (message, status = 400) => {
  return jsonResponse({ error: message }, status);
};

const toVideoPayload = (row) => ({
  id: row.id,
  title: row.title,
  channel: row.channel,
  views: row.views,
  date: row.date,
  duration: row.duration,
  thumbnail: row.thumbnail,
  category: row.category,
  videoUrl: row.video_url,
  description: row.description,
});

const parseId = (pathname) => {
  const parts = pathname.split('/').filter(Boolean);
  const idPart = parts[parts.length - 1];
  const id = Number.parseInt(idPart, 10);
  return Number.isNaN(id) ? null : id;
};

const readJson = async (request) => {
  try {
    return await request.json();
  } catch {
    return null;
  }
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.startsWith('/api/videos')) {
      if (!env.DB) {
        return errorResponse('Database binding not configured.', 500);
      }

      if (request.method === 'GET' && url.pathname === '/api/videos') {
        const { results } = await env.DB.prepare(
          'SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos ORDER BY id DESC'
        ).all();
        return jsonResponse(results.map(toVideoPayload));
      }

      if (request.method === 'POST' && url.pathname === '/api/videos') {
        const body = await readJson(request);
        if (!body) {
          return errorResponse('Invalid JSON payload.');
        }

        const requiredFields = ['title', 'channel', 'videoUrl', 'category', 'duration', 'views', 'date', 'description'];
        for (const field of requiredFields) {
          if (!body[field] || String(body[field]).trim() === '') {
            return errorResponse(`Missing field: ${field}`);
          }
        }

        const thumbnail = body.thumbnail || '';
        const insert = await env.DB.prepare(
          `INSERT INTO videos (title, channel, views, date, duration, thumbnail, category, video_url, description, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
        )
          .bind(
            body.title.trim(),
            body.channel.trim(),
            body.views.trim(),
            body.date.trim(),
            body.duration.trim(),
            thumbnail.trim(),
            body.category.trim(),
            body.videoUrl.trim(),
            body.description.trim()
          )
          .run();

        const id = insert.meta.last_row_id;
        const { results } = await env.DB.prepare(
          'SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos WHERE id = ?'
        )
          .bind(id)
          .all();

        return jsonResponse(toVideoPayload(results[0]), 201);
      }

      if (request.method === 'PUT') {
        const id = parseId(url.pathname);
        if (!id) {
          return errorResponse('Invalid video id.', 400);
        }

        const body = await readJson(request);
        if (!body) {
          return errorResponse('Invalid JSON payload.');
        }

        const requiredFields = ['title', 'channel', 'videoUrl', 'category', 'duration', 'views', 'date', 'description'];
        for (const field of requiredFields) {
          if (!body[field] || String(body[field]).trim() === '') {
            return errorResponse(`Missing field: ${field}`);
          }
        }

        const thumbnail = body.thumbnail || '';
        const update = await env.DB.prepare(
          `UPDATE videos
           SET title = ?, channel = ?, views = ?, date = ?, duration = ?, thumbnail = ?, category = ?, video_url = ?, description = ?, updated_at = CURRENT_TIMESTAMP
           WHERE id = ?`
        )
          .bind(
            body.title.trim(),
            body.channel.trim(),
            body.views.trim(),
            body.date.trim(),
            body.duration.trim(),
            thumbnail.trim(),
            body.category.trim(),
            body.videoUrl.trim(),
            body.description.trim(),
            id
          )
          .run();

        if (update.meta.changes === 0) {
          return errorResponse('Video not found.', 404);
        }

        const { results } = await env.DB.prepare(
          'SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos WHERE id = ?'
        )
          .bind(id)
          .all();

        return jsonResponse(toVideoPayload(results[0]));
      }

      if (request.method === 'DELETE') {
        const id = parseId(url.pathname);
        if (!id) {
          return errorResponse('Invalid video id.', 400);
        }

        const result = await env.DB.prepare('DELETE FROM videos WHERE id = ?').bind(id).run();
        if (result.meta.changes === 0) {
          return errorResponse('Video not found.', 404);
        }
        return jsonResponse({ success: true });
      }

      return errorResponse('Not found.', 404);
    }

    if (env.ASSETS && env.ASSETS.fetch) {
      return env.ASSETS.fetch(request);
    }

    return errorResponse('Assets binding not configured.', 500);
  },
};
