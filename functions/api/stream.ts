export const onRequestGet: PagesFunction = async ({ request }) => {
	const { searchParams } = new URL(request.url)
	const service = searchParams.get("service") || ""
	const method = searchParams.get("method") || ""

	const stream = new ReadableStream<Uint8Array>({
		start(controller) {
			const encoder = new TextEncoder()
			function send(obj: unknown) {
				controller.enqueue(encoder.encode(`data: ${JSON.stringify(obj)}\n\n`))
			}
			function ping() {
				controller.enqueue(encoder.encode(`: ping\n\n`))
			}

			// Emit initial messages based on subscription
			if (service === "cline.StateService" && method === "subscribeToState") {
				const state = {
					stateJson: JSON.stringify({
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
					}),
				}
				send(state)
			}

			if (service === "cline.UiService" && method === "subscribeToTheme") {
				send({ value: JSON.stringify({}) })
			}

			if (service === "cline.FileService" && method === "subscribeToWorkspaceUpdates") {
				send({ values: [] })
			}

			if (service === "cline.UiService" && method === "subscribeToChatButtonClicked") {
				// No-op events; stream stays open
			}

			// Keep-alive pings
			const interval = setInterval(ping, 15000)

			return () => {
				clearInterval(interval)
			}
		},
	})

	return new Response(stream, {
		headers: {
			"content-type": "text/event-stream",
			"cache-control": "no-cache, no-transform",
			connection: "keep-alive",
			"access-control-allow-origin": "*",
		},
	})
}
