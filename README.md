# NijAI — নিজের টার্মিনাল AI সহকারী

> **প্রথম সংস্করণ / পরীক্ষামূলক।** Python-এর standard library দিয়ে তৈরি, OpenRouter-এর browser login ব্যবহার করে। এটি Hermes-এর কপি নয় এবং Hermes-এর সব ফিচার নেই। Android ফোনে বাস্তব Termux/proot পরীক্ষা এবং OpenRouter অ্যাকাউন্ট দিয়ে end-to-end login এখনও করা হয়নি। উৎপাদন ব্যবহারের আগে নিজের ডিভাইসে পরীক্ষা করুন।

NijAI চালু হয় টার্মিনালে। এটি OpenRouter-এর মডেলের সঙ্গে চ্যাট করতে পারে এবং আপনার অনুমতি নিয়ে ফাইল পড়া, নাম দিয়ে খোঁজা, ফাইল লেখা ও শেল কমান্ড চালাতে পারে। **প্রতিটি টুলের জন্য আলাদা অনুমতি চাওয়া হয়।**

## কেন এই ডিজাইন?

পূর্বের সেটআপে Android বনাম Ubuntu Python, Rust build, Node build, process kill, PATH এবং ফ্রি মডেলের rate limit সমস্যা হয়েছিল। তাই:

- Python 3.9+ ও তার standard library ছাড়া pip, Rust, Node, uv বা venv লাগে না।
- ইনস্টলার Python ও SSL যাচাই করে, launcher পরীক্ষা করে এবং Bash PATH কনফিগার করে।
- Browser login-এ OpenRouter-এর headless PKCE ব্যবহার হয়: browser-এ লগইন করে **authorization code একবার কপি-পেস্ট** করতে হয়। কোনো localhost callback বা server প্রয়োজন নেই।
- 429 rate limit এ সীমাহীন retry নয়; পরিষ্কার বার্তা দেখায়। এটি provider-এর সীমা সরাতে পারে না।
- Ubuntu-তে Python যদি ভুল করে Android ABI হয়, ইনস্টলার থেমে সতর্ক করে।

এগুলো সতর্কতা—সব ডিভাইসে error-free কাজের নিশ্চয়তা নয়।

## একটি কমান্ডে Termux ইনস্টল

**প্রথমে repository-তে এই প্রজেক্টের ফাইলগুলো `main` branch-এর root-এ আপলোড করতে হবে।** বিশেষ করে `bootstrap.sh`, `install.sh` এবং `nijai.py`। ফাইল আপলোডের আগে নিচের লিংকে 404 আসবে। Public repo না হলে unauthenticated clone-ও ব্যর্থ হতে পারে।

F-Droid বা অফিসিয়াল GitHub থেকে standard Termux ইনস্টল করে খুলুন। **Ubuntu/proot-এ ঢুকবেন না।** Internet প্রয়োজন। Termux-এর ভেতর এক লাইন চালান:

```bash
pkg install -y curl && (set -o pipefail; curl -fsSL https://raw.githubusercontent.com/yeaminuli7/ai/main/bootstrap.sh | bash)
```

এটি `curl`, তারপর `python`, `git`, `ca-certificates` Termux package ইনস্টল/আপডেট করতে পারে, `main` branch clone করে অ্যাপ ইনস্টল ও launcher যাচাই করে। ইন্টার‌্যাকটিভ টার্মিনালে প্রথম সেটআপ শুরু হয়; browser login চাইলে অনুমতি দিতে হবে। ইনস্টলার shell-এর বর্তমান parent environment পরিবর্তন করতে পারে না; পরবর্তী command-এর জন্য প্রয়োজনে `export PATH="$HOME/.local/bin:$PATH"` চালান।

**নিরাপত্তা:** এই কমান্ড GitHub-এর পরিবর্তনযোগ্য `main` branch থেকে code download ও execute করে। URL ও source আগে পর্যালোচনা করুন; কেবল repository-কে বিশ্বাস করলে চালান। এটি কোনো checksum বা স্বাক্ষর দিয়ে code যাচাই করে না। নিরাপদ release-এর জন্য audited, নির্দিষ্ট commit বা স্বাক্ষরিত release ব্যবহার করার ব্যবস্থা পরে যোগ করুন।

ইনস্টল হয় `~/.local/share/nijai`-এ, launcher থাকে `~/.local/bin/nijai`। Installer Bash-এর `~/.bashrc`-এ PATH যোগ করে। আপডেটের জন্য একই এক-কমান্ড আবার চালাতে পারেন; configuration থাকবে। Native Termux ও Ubuntu proot-এর data আলাদা।

### আগের মতো clone করে ইনস্টল (developer বা Ubuntu proot)

```bash
git clone https://github.com/yeaminuli7/ai.git
cd ai
bash install.sh
export PATH="$HOME/.local/bin:$PATH"
nijai
```

এই পথটি আগে থেকেই Python 3.9+, Git ও CA certificates থাকা ধরে নেয়। `bootstrap.sh` শুধু standard native Termux-এর জন্য; Ubuntu/proot তৈরি করে না।

## OpenRouter দিয়ে লগইন

1. এক-কমান্ড setup-এ চাইলে login নির্বাচন করুন; অথবা পরে `nijai` চালিয়ে `/login` লিখুন।
2. দেওয়া URL ফোনের ব্রাউজারে খুলুন (স্বয়ংক্রিয়ভাবে না খুললে URL কপি করুন)।
3. OpenRouter-এ লগইন করে অ্যাপ অনুমোদন করুন।
4. OpenRouter যে **authorization code** দেখাবে, সেটি অ্যাপের hidden prompt-এ পেস্ট করুন। এই code অন্য কাউকে দেবেন না।

OpenRouter-এর headless PKCE flow এই কপি-পেস্ট পদ্ধতি সমর্থন করে। Credential `~/.config/nijai/config.json`-এ plaintext হিসেবে সংরক্ষণ হয় (XDG_CONFIG_HOME থাকলে সেটির নিচে); ফাইল permission 0600 করার চেষ্টা করা হয়। এটি encrypted keychain নয়। `/logout` স্থানীয় key মুছে, কিন্তু OpenRouter সার্ভারে key revoke করতে আপনাকে OpenRouter dashboard ব্যবহার করতে হবে। কোনো key, code বা config ফাইল শেয়ার করবেন না।

## কমান্ড

| কমান্ড | কাজ |
|---|---|
| `/login` | Browser দিয়ে OpenRouter অথরাইজেশন |
| `/models` | OpenRouter থেকে বর্তমানে free হিসেবে তালিকাভুক্ত মডেল দেখায় |
| `/model ID` | মডেল বদলায়, যেমন `/model openrouter/free` |
| `/new` | বর্তমান মেমোরি-চ্যাট মুছে |
| `/logout` | স্থানীয় credential সরায় |
| `/help` | সাহায্য |
| `/exit` | অ্যাপ থেকে বের হয় |
| `nijai --doctor` | অফলাইন পরিবেশ পরীক্ষা |
| `nijai --version` | সংস্করণ দেখে |

ডিফল্ট `openrouter/free` router একটি উপলব্ধ ফ্রি মডেল বেছে নেয়। সব মডেল সব ফিচার বা tools সমর্থন করে না। ফ্রি মডেলের প্রাপ্যতা ও rate limit পরিবর্তিত হতে পারে; এই অ্যাপ সেগুলো বাইপাস করে না। `:free` নয় এমন model ID দিলে সম্ভাব্য খরচ সম্পর্কে সতর্ক করে এবং নিশ্চিতকরণ চায়। OpenRouter-এর বিলিং সর্বদা নিজে পরীক্ষা করুন।

## নিরাপত্তা ও গোপনীয়তা

- প্রম্পট, চ্যাট ইতিহাস এবং **অনুমোদিত টুল আউটপুট OpenRouter ও নির্বাচিত মডেল provider-এর কাছে যায়**। এগুলোতে সংবেদনশীল তথ্য রাখবেন না। কথোপকথন শুধু প্রক্রিয়ার মেমোরিতে রাখা হয়; নিজস্ব চ্যাট log লেখা হয় না।
- Local shell এবং proot **security sandbox নয়**। অনুমোদিত কমান্ড আপনার user-এর ক্ষমতা অনুযায়ী ফাইল পরিবর্তন, মুছে ফেলা বা নেটওয়ার্ক ব্যবহার করতে পারে। প্রতিটি অনুরোধ যাচাই করুন।
- Tool execution model/provider-এর tool-call সমর্থনের ওপর নির্ভর করে। প্রতিটি টুল অনুমতির জন্য স্পষ্ট `yes` প্রয়োজন।
- Code একটি prototype; symbolic link বা ফাইল একসঙ্গে পরিবর্তিত হওয়ার মতো race condition থেকে এটিকে নিরাপত্তা boundary হিসেবে বিবেচনা করবেন না। নতুন app-এর জন্য আলাদা অপ্রয়োজনীয় গোপন তথ্যবিহীন environment ব্যবহার করুন।
- `/logout` শুধু স্থানীয় key মুছে; OpenRouter dashboard-এ key revoke করুন। Environment variable `OPENROUTER_API_KEY` ব্যবহৃত হলে সেটি `/logout` মুছে না।

## সমস্যা সমাধান

- **`nijai: command not found`:** `export PATH="$HOME/.local/bin:$PATH"` চালান। `ls -l ~/.local/bin/nijai` দিয়ে পরীক্ষা করুন। Bash-এর বদলে অন্য shell ব্যবহার করলে তার startup file-এ PATH নিজে যোগ করতে হবে।
- **`python3: command not found`:** Ubuntu-তে `apt install python3`; Termux-এ `pkg install python`।
- **Ubuntu-তে Android Python:** `export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; hash -r` করে `python3 -c 'import sys; print(sys.executable, sys.platform)'` পরীক্ষা করুন। প্রয়োজনে `apt install python3`।
- **429:** কিছুক্ষণ অপেক্ষা বা অন্য ফ্রি মডেল ব্যবহার করুন; সীমা অ্যাকাউন্ট জুড়ে থাকলে মডেল বদলালেও সমাধান নাও হতে পারে।
- **401:** `/login` আবার চালান। **402:** ফ্রি মডেল নির্বাচন বা OpenRouter credits পরীক্ষা করুন।
- **Browser খোলে না:** অ্যাপে দেখানো URL ম্যানুয়ালি ফোনের ব্রাউজারে খুলুন।
- **`/storage/emulated/0` permission:** native Termux-এ `termux-setup-storage` চালিয়ে permission দিন, তারপর proot-এ path আছে কি না দেখুন। সব ডিভাইসে একই path বা bind নিশ্চিত নয়।
- **Signal 9:** Android app/process restriction বা memory pressure কারণ হতে পারে, নিশ্চিত নয়। Termux foreground-এ রাখুন, অন্য অ্যাপ বন্ধ করুন এবং প্রয়োজনে Android Developer Options-এর child-process restriction পরীক্ষা করুন।

## Developer tests

```bash
python3 -m unittest discover -s tests -v
bash -n install.sh
```

পরীক্ষাগুলো mock ব্যবহার করে; লাইভ OpenRouter credentials বা প্রকৃত Android ডিভাইসের বিকল্প নয়।

## OpenRouter reference

- https://openrouter.ai/docs/use-cases/oauth-pkce
- https://openrouter.ai/docs/api_reference/overview
- https://openrouter.ai/docs/guides/routing/routers/free-router
