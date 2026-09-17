import time
from playwright.sync_api import sync_playwright

def verify_maintenance_workflow():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()

        print("Starting verification...")

        # 1. Login
        page.goto("http://localhost:3000/users/sign_in")
        page.fill("input[name='user[email]']", "admin@mim.cl")
        page.fill("input[name='user[password]']", "password")
        page.click("input[type='submit']")
        page.wait_for_url("http://localhost:3000/")
        print("Logged in.")

        # 2. Create Asset Category with Plan
        page.goto("http://localhost:3000/asset_categories/new")
        page.wait_for_selector("#modal_body")

        page.fill("input[name='asset_category[name]']", "Camión Minero")
        page.check("input[id='icon_fa-truck']") # Select icon

        # Switch to Structure Tab
        page.click("button#structure-tab")

        # Add Component
        page.click("button:has-text('Agregar Grupo de Componentes')")
        page.wait_for_selector("input[placeholder*='Nombre del Grupo']")
        page.fill("input[placeholder*='Nombre del Grupo']", "Motor")

        # Add SubComponent
        page.click("button:has-text('Agregar Parte')")
        page.wait_for_selector("input[placeholder*='Nombre del Sub-componente']")
        page.fill("input[placeholder*='Nombre del Sub-componente']", "Filtro Aceite")

        # Add Maintenance Plan
        page.click("button:has-text('Agregar Regla de Mantenimiento')")
        page.wait_for_selector("input[placeholder='Ej. Cambio de Aceite']")
        page.fill("input[placeholder='Ej. Cambio de Aceite']", "Cambio 10k")
        page.fill("input[placeholder='Ej. 5000']", "10000")
        page.select_option("select[name*='unit']", "KM")

        page.click("input[type='submit']")
        page.wait_for_load_state("networkidle")
        print("Created Asset Category with Rule.")

        # 3. Create Asset
        page.goto("http://localhost:3000/maquinaria/new")
        page.wait_for_selector("#modal_body")

        page.fill("input[name='asset[name]']", "Camión 001")
        page.fill("input[name='asset[plate]']", "CA-001")
        page.select_option("select[name='asset[asset_category_id]']", label="Camión Minero")

        # Tag Selection
        # Wait for the select to be populated? It's server side rendered.
        tag_select = page.locator("select[name='asset[tag_id]']")
        # Select by value if possible, or index
        # We created a tag 'General', let's try selecting it.
        # Check if option exists
        if tag_select.locator("option", has_text="General").count() > 0:
            tag_select.select_option(label="General")
        else:
             print("Tag 'General' not found in select. Selecting index 1.")
             tag_select.select_option(index=1)

        page.select_option("select[name='asset[status]']", "Operativa")

        page.click("input[type='submit']")

        # Validation check
        time.sleep(1)
        if page.locator(".invalid-feedback").is_visible():
            print("Validation failed!")
            # Print visible errors
            print(page.locator(".invalid-feedback:visible").all_inner_texts())
            exit(1)

        page.wait_for_url("**/maquinaria/*")
        print("Created Asset.")

        # 4. Configure Meter
        current_url = page.url
        if "maquinaria/new" in current_url:
             print("Still on new page. Failed.")
             exit(1)

        if current_url.endswith("maquinaria"):
             # If we landed on index, click the asset
             page.click("text=Camión 001")

        page.wait_for_selector("a:has-text('Configurar Medidores')")
        page.click("a:has-text('Configurar Medidores')")

        page.wait_for_selector("#large_modal_body")

        # Add Meter
        page.click("a:has-text('Agregar Medidor')")
        page.fill("input[name*='[name]']", "Odómetro")
        page.select_option("select[name*='[unit]']", "KM")
        page.fill("input[name*='[current_value]']", "0")

        page.click("input[type='submit']")
        print("Configured Meter.")

        # 5. Verify Initial Status (White)
        page.reload()
        assert page.is_visible("text=0.0%")
        print("Verified Initial Status (0%).")

        # 6. Update Logbook
        asset_id = page.url.split("/")[-1]
        page.goto(f"http://localhost:3000/bitacora/new?asset_id={asset_id}")

        page.fill("input[type='number']", "8000")
        page.click("input[type='submit']")
        print("Updated Logbook (8000 KM).")

        # 7. Verify Status (Orange)
        page.goto(f"http://localhost:3000/maquinaria/{asset_id}")
        assert page.is_visible("text=80.0%")
        assert page.locator(".progress-bar.bg-orange").is_visible()
        print("Verified Warning Status (Orange).")

        # 8. Reset
        page.on("dialog", lambda dialog: dialog.accept())
        page.click("button:has-text('Reiniciar')")

        # 9. Verify Reset
        page.wait_for_load_state("networkidle")
        assert page.is_visible("text=0.0%")
        assert page.locator(".progress-bar.bg-success").is_visible()
        print("Verified Reset.")

        browser.close()

if __name__ == "__main__":
    verify_maintenance_workflow()
