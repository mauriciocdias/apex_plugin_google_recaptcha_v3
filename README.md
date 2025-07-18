# Google reCaptcha v3 Plugin for Oracle APEX

This Oracle APEX plugin implements **Google reCAPTCHA v3**, allowing you to validate human interactions without interrupting the user experience.  
It is inspired by [Mohamed Zebib's reCAPTCHA v2 plugin](https://apex.world/ords/r/apex_world/apex-world/plug-in-details?p710_plg_int_name=ca.mzebib.captcha2&clear=710).

> ✅ Compatible with APEX 5+  
> 🌐 Supports restricted environments via recaptcha.net  
> 🔐 Validates reCAPTCHA score server-side  
> 🧩 Easy integration using a hidden item

---

## 🔧 Features

- Implements **Google reCAPTCHA v3** client-side rendering
- Validates the token on submit using Google’s siteverify API
- Customizable **score threshold** (default: `0.5`)
- Custom **error message** and **display location**
- Supports **custom submit button selector** (ID or class)
- Allows using **recaptcha.net** for clients that block google.com
- Optional **language selection**

---

## 🚀 Installation

1. Import the file `item_type_plugin_br_recaptcha_v3_plugin.sql` into your Oracle APEX workspace.
2. Navigate to **Shared Components > Plugins**
3. Locate `Google reCAPTCHA v3 APEX 5`
4. Create a new **Page Item** using this plugin

---

## 🔑 Required Setup

Register your domain at [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin/create)  
You will get:

- **Site Key** (public)
- **Secret Key** (private)

---

## ⚙️ Plugin Configuration

### 🔐 Application-Level Attributes

| Attribute                 | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| **Public Key**           | Your site's public reCAPTCHA key                                           |
| **Private Key**          | Your secret reCAPTCHA key for server-side verification                     |
| **Wallet Path**          | Oracle wallet path for HTTPS requests (optional)                           |
| **Wallet Password**      | Oracle wallet password (optional)                                          |
| **Verification URL**     | URL to the reCAPTCHA verification endpoint (default: `https://google.com/...`) |
| **IP Address Function**  | PL/SQL expression to fetch client IP (default: `owa_util.get_cgi_env('REMOTE_ADDR')`) |
| **JS URL for reCAPTCHA** | reCAPTCHA JavaScript loader URL (use `recaptcha.net` if `google.com` is blocked) |

---

### 🧩 Page Item Attributes

| Attribute                               | Description                                                                 |
|----------------------------------------|-----------------------------------------------------------------------------|
| **Submit Button Selector**             | CSS selector for the button that triggers submission (`#B_SUBMIT`, `.btn`) |
| **Score Threshold**                    | Minimum score for successful verification (default: `0.5`)                 |
| **Error Message**                      | Custom message when score is not reached                                   |
| **Error Display Location**             | Where to show the error (inline, notification, etc.)                       |
| **Language**                           | reCAPTCHA language code (e.g., `en`, `pt-BR`, `es`)                        |

---

## 🛠 Example Usage

1. Add a hidden item using this plugin (e.g. `P1_RECAPTCHA`)
2. Set `Submit Button Selector` to match the ID/class of your submit button (e.g. `#B_SUBMIT`)
3. In your process or validation, the plugin will:
   - Automatically execute reCAPTCHA on button click
   - Submit the page only after the token is received
   - Validate the token server-side and compare the score

---

## 💡 Tips

- Your submit button **must have Action=Defined by Dynamic Action**, not `submit`.
- If your users block `google.com`, change the JS URL to `https://www.recaptcha.net/recaptcha/api.js`.
- Use `apex_debug.enable` to trace plugin behavior during development.
- The plugin sets session state with status like `RECAPTCHA-V3-SUCCESS`, `FAILED`, or `UNSUCESSFUL-CALL`.

---

## 📜 License

This plugin is provided as-is for educational and integration purposes.

---

## 🙋‍♂️ Author

**Maurício Carlos Dias**  
📧 [mauriciocdias@gmail.com](mailto:mauriciocdias@gmail.com)

