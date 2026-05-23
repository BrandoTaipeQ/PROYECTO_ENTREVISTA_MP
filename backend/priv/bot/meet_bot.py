import asyncio
import sys
from playwright.async_api import async_playwright

async def run(meeting_url):
    async with async_playwright() as p:
        # Launch browser in headless mode
        browser = await p.chromium.launch(headless=True)

        # Create a context with camera and microphone permissions
        context = await browser.new_context(
            permissions=['microphone', 'camera'],
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        )

        page = await context.new_page()

        print(f"Joining meeting: {meeting_url}")
        await page.goto(meeting_url)

        # Handle Google Meet's initial screen
        try:
            # Type name if requested
            name_input = await page.wait_for_selector('input[type="text"]', timeout=10000)
            if name_input:
                await name_input.fill("AI Detection Bot")
                await name_input.press("Enter")

            # Click "Join" or "Ask to join" button
            # This selector might need adjustment based on Google Meet's current UI
            join_button = await page.wait_for_selector('span:has-text("Join now"), span:has-text("Ask to join")', timeout=10000)
            await join_button.click()

            print("Successfully joined the meeting.")

            # Keep the bot alive for 30 minutes or until the process is killed
            await asyncio.sleep(1800)

        except Exception as e:
            print(f"Error during meeting join: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python meet_bot.py <meeting_url>")
        sys.exit(1)

    url = sys.argv[1]
    asyncio.run(run(url))
