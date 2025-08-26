export const onRequestPost: PagesFunction = async ({ request, env }) => {
	try {
		const body = await request.json()
		const service: string = body?.service || ""
		const method: string = body?.method || ""
		const message = body?.message || {}

		// Route by service + method
		if (service === "cline.UiService" && method === "initializeWebview") {
			return json({ message: {} })
		}

		if (service === "cline.UiService" && method === "onDidShowAnnouncement") {
			return json({ message: { value: false } })
		}

		if (service === "cline.StateService" && method === "getLatestState") {
			// Try to read from D1
			let row: any | null = null
			try {
				// @ts-ignore DB bound by wrangler [[d1_databases]]
				const db = (env as any).DB as D1Database
				await db.exec("CREATE TABLE IF NOT EXISTS state (id INTEGER PRIMARY KEY, state_json TEXT NOT NULL);")
				const sel = await db.prepare("SELECT state_json FROM state WHERE id=1").first<any>()
				row = sel || null
			} catch (e) {}

			if (row?.state_json) {
				return json(JSON.parse(row.state_json))
			}

			// Default snapshot if none in DB
			const state = {
				version: "web-standalone",
				clineMessages: [],
				taskHistory: [],
				shouldShowAnnouncement: false,
				autoApprovalSettings: { version: 1 },
				browserSettings: { openLinksIn: "system", openImagesIn: "system" },
				preferredLanguage: "English",
				openaiReasoningEffort: "medium",
				mode: "act",
				platform: { type: "vscode", version: "web" },
				telemetrySetting: "unset",
				distinctId: "web-guest",
				planActSeparateModelsSetting: true,
				enableCheckpointsSetting: true,
				mcpDisplayMode: "collapsed",
				globalClineRulesToggles: {},
				localClineRulesToggles: {},
				localCursorRulesToggles: {},
				localWindsurfRulesToggles: {},
				localWorkflowToggles: {},
				globalWorkflowToggles: {},
				shellIntegrationTimeout: 4000,
				terminalReuseEnabled: true,
				terminalOutputLineLimit: 500,
				defaultTerminalProfile: "default",
				isNewUser: true,
				welcomeViewCompleted: false,
				mcpResponsesCollapsed: false,
			}
			try {
				// @ts-ignore
				const db = (env as any).DB as D1Database
				await db.prepare("DELETE FROM state WHERE id=1").run()
				await db.prepare("INSERT INTO state (id, state_json) VALUES (1, ?)\n").bind(JSON.stringify(state)).run()
			} catch (e) {}
			return json(state)
		}

		// Default: not implemented
		return new Response(JSON.stringify({ error: `Not implemented: ${service}.${method}` }), {
			status: 501,
			headers: { "content-type": "application/json; charset=utf-8" },
		})
	} catch (error: any) {
		return new Response(JSON.stringify({ error: String(error?.message || error) }), {
			status: 500,
			headers: { "content-type": "application/json; charset=utf-8" },
		})
	}
}

function json(data: unknown, status = 200): Response {
	return new Response(JSON.stringify(data), {
		status,
		headers: { "content-type": "application/json; charset=utf-8" },
	})
}
