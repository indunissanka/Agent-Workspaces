var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/worker.js
var jsonResponse = /* @__PURE__ */ __name((data, status = 200) => {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json"
    }
  });
}, "jsonResponse");
var errorResponse = /* @__PURE__ */ __name((message, status = 400) => {
  return jsonResponse({ error: message }, status);
}, "errorResponse");
var toVideoPayload = /* @__PURE__ */ __name((row) => ({
  id: row.id,
  title: row.title,
  channel: row.channel,
  views: row.views,
  date: row.date,
  duration: row.duration,
  thumbnail: row.thumbnail,
  category: row.category,
  videoUrl: row.video_url,
  description: row.description
}), "toVideoPayload");
var parseId = /* @__PURE__ */ __name((pathname) => {
  const parts = pathname.split("/").filter(Boolean);
  const idPart = parts[parts.length - 1];
  const id = Number.parseInt(idPart, 10);
  return Number.isNaN(id) ? null : id;
}, "parseId");
var readJson = /* @__PURE__ */ __name(async (request) => {
  try {
    return await request.json();
  } catch {
    return null;
  }
}, "readJson");
var worker_default = {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/api/videos")) {
      if (!env.DB) {
        return errorResponse("Database binding not configured.", 500);
      }
      if (request.method === "GET" && url.pathname === "/api/videos") {
        const { results } = await env.DB.prepare(
          "SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos ORDER BY id DESC"
        ).all();
        return jsonResponse(results.map(toVideoPayload));
      }
      if (request.method === "POST" && url.pathname === "/api/videos") {
        const body = await readJson(request);
        if (!body) {
          return errorResponse("Invalid JSON payload.");
        }
        const requiredFields = ["title", "channel", "videoUrl", "category", "duration", "views", "date", "description"];
        for (const field of requiredFields) {
          if (!body[field] || String(body[field]).trim() === "") {
            return errorResponse(`Missing field: ${field}`);
          }
        }
        const thumbnail = body.thumbnail || "";
        const insert = await env.DB.prepare(
          `INSERT INTO videos (title, channel, views, date, duration, thumbnail, category, video_url, description, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
        ).bind(
          body.title.trim(),
          body.channel.trim(),
          body.views.trim(),
          body.date.trim(),
          body.duration.trim(),
          thumbnail.trim(),
          body.category.trim(),
          body.videoUrl.trim(),
          body.description.trim()
        ).run();
        const id = insert.meta.last_row_id;
        const { results } = await env.DB.prepare(
          "SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos WHERE id = ?"
        ).bind(id).all();
        return jsonResponse(toVideoPayload(results[0]), 201);
      }
      if (request.method === "PUT") {
        const id = parseId(url.pathname);
        if (!id) {
          return errorResponse("Invalid video id.", 400);
        }
        const body = await readJson(request);
        if (!body) {
          return errorResponse("Invalid JSON payload.");
        }
        const requiredFields = ["title", "channel", "videoUrl", "category", "duration", "views", "date", "description"];
        for (const field of requiredFields) {
          if (!body[field] || String(body[field]).trim() === "") {
            return errorResponse(`Missing field: ${field}`);
          }
        }
        const thumbnail = body.thumbnail || "";
        const update = await env.DB.prepare(
          `UPDATE videos
           SET title = ?, channel = ?, views = ?, date = ?, duration = ?, thumbnail = ?, category = ?, video_url = ?, description = ?, updated_at = CURRENT_TIMESTAMP
           WHERE id = ?`
        ).bind(
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
        ).run();
        if (update.meta.changes === 0) {
          return errorResponse("Video not found.", 404);
        }
        const { results } = await env.DB.prepare(
          "SELECT id, title, channel, views, date, duration, thumbnail, category, video_url, description FROM videos WHERE id = ?"
        ).bind(id).all();
        return jsonResponse(toVideoPayload(results[0]));
      }
      if (request.method === "DELETE") {
        const id = parseId(url.pathname);
        if (!id) {
          return errorResponse("Invalid video id.", 400);
        }
        const result = await env.DB.prepare("DELETE FROM videos WHERE id = ?").bind(id).run();
        if (result.meta.changes === 0) {
          return errorResponse("Video not found.", 404);
        }
        return jsonResponse({ success: true });
      }
      return errorResponse("Not found.", 404);
    }
    if (env.ASSETS && env.ASSETS.fetch) {
      return env.ASSETS.fetch(request);
    }
    return errorResponse("Assets binding not configured.", 500);
  }
};

// ../../../../opt/homebrew/lib/node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
var drainBody = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } finally {
    try {
      if (request.body !== null && !request.bodyUsed) {
        const reader = request.body.getReader();
        while (!(await reader.read()).done) {
        }
      }
    } catch (e) {
      console.error("Failed to drain the unused request body.", e);
    }
  }
}, "drainBody");
var middleware_ensure_req_body_drained_default = drainBody;

// ../../../../opt/homebrew/lib/node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
function reduceError(e) {
  return {
    name: e?.name,
    message: e?.message ?? String(e),
    stack: e?.stack,
    cause: e?.cause === void 0 ? void 0 : reduceError(e.cause)
  };
}
__name(reduceError, "reduceError");
var jsonError = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } catch (e) {
    const error = reduceError(e);
    return Response.json(error, {
      status: 500,
      headers: { "MF-Experimental-Error-Stack": "true" }
    });
  }
}, "jsonError");
var middleware_miniflare3_json_error_default = jsonError;

// .wrangler/tmp/bundle-66tmAr/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = worker_default;

// ../../../../opt/homebrew/lib/node_modules/wrangler/templates/middleware/common.ts
var __facade_middleware__ = [];
function __facade_register__(...args) {
  __facade_middleware__.push(...args.flat());
}
__name(__facade_register__, "__facade_register__");
function __facade_invokeChain__(request, env, ctx, dispatch, middlewareChain) {
  const [head, ...tail] = middlewareChain;
  const middlewareCtx = {
    dispatch,
    next(newRequest, newEnv) {
      return __facade_invokeChain__(newRequest, newEnv, ctx, dispatch, tail);
    }
  };
  return head(request, env, ctx, middlewareCtx);
}
__name(__facade_invokeChain__, "__facade_invokeChain__");
function __facade_invoke__(request, env, ctx, dispatch, finalMiddleware) {
  return __facade_invokeChain__(request, env, ctx, dispatch, [
    ...__facade_middleware__,
    finalMiddleware
  ]);
}
__name(__facade_invoke__, "__facade_invoke__");

// .wrangler/tmp/bundle-66tmAr/middleware-loader.entry.ts
var __Facade_ScheduledController__ = class ___Facade_ScheduledController__ {
  constructor(scheduledTime, cron, noRetry) {
    this.scheduledTime = scheduledTime;
    this.cron = cron;
    this.#noRetry = noRetry;
  }
  static {
    __name(this, "__Facade_ScheduledController__");
  }
  #noRetry;
  noRetry() {
    if (!(this instanceof ___Facade_ScheduledController__)) {
      throw new TypeError("Illegal invocation");
    }
    this.#noRetry();
  }
};
function wrapExportedHandler(worker) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return worker;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  const fetchDispatcher = /* @__PURE__ */ __name(function(request, env, ctx) {
    if (worker.fetch === void 0) {
      throw new Error("Handler does not export a fetch() function.");
    }
    return worker.fetch(request, env, ctx);
  }, "fetchDispatcher");
  return {
    ...worker,
    fetch(request, env, ctx) {
      const dispatcher = /* @__PURE__ */ __name(function(type, init) {
        if (type === "scheduled" && worker.scheduled !== void 0) {
          const controller = new __Facade_ScheduledController__(
            Date.now(),
            init.cron ?? "",
            () => {
            }
          );
          return worker.scheduled(controller, env, ctx);
        }
      }, "dispatcher");
      return __facade_invoke__(request, env, ctx, dispatcher, fetchDispatcher);
    }
  };
}
__name(wrapExportedHandler, "wrapExportedHandler");
function wrapWorkerEntrypoint(klass) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return klass;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  return class extends klass {
    #fetchDispatcher = /* @__PURE__ */ __name((request, env, ctx) => {
      this.env = env;
      this.ctx = ctx;
      if (super.fetch === void 0) {
        throw new Error("Entrypoint class does not define a fetch() function.");
      }
      return super.fetch(request);
    }, "#fetchDispatcher");
    #dispatcher = /* @__PURE__ */ __name((type, init) => {
      if (type === "scheduled" && super.scheduled !== void 0) {
        const controller = new __Facade_ScheduledController__(
          Date.now(),
          init.cron ?? "",
          () => {
          }
        );
        return super.scheduled(controller);
      }
    }, "#dispatcher");
    fetch(request) {
      return __facade_invoke__(
        request,
        this.env,
        this.ctx,
        this.#dispatcher,
        this.#fetchDispatcher
      );
    }
  };
}
__name(wrapWorkerEntrypoint, "wrapWorkerEntrypoint");
var WRAPPED_ENTRY;
if (typeof middleware_insertion_facade_default === "object") {
  WRAPPED_ENTRY = wrapExportedHandler(middleware_insertion_facade_default);
} else if (typeof middleware_insertion_facade_default === "function") {
  WRAPPED_ENTRY = wrapWorkerEntrypoint(middleware_insertion_facade_default);
}
var middleware_loader_entry_default = WRAPPED_ENTRY;
export {
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=worker.js.map
