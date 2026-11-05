# GitHub-এ NijAI প্রকাশ

নির্বাচিত repository: **https://github.com/yeaminuli7/ai**, branch: `main`।

আমি এই workspace থেকে আপনার GitHub account-এ push করিনি। GitHub-এ repository root-এ প্রকল্পের ফাইলগুলো আপলোড করুন। এক-কমান্ড installer কাজ করার জন্য অন্তত এই তিনটি ফাইল জরুরি:

```text
bootstrap.sh
install.sh
nijai.py
```

README.md ও LICENSE-সহ পুরো প্রকল্প রাখা ভালো। `tests/` এবং `.github/workflows/` রাখলে automated tests-ও যুক্ত হবে। ZIP extract করলে একটি `nijai` ফোল্ডার পাবেন: **ফোল্ডারের ভেতরের ফাইলগুলো** repository root-এ দিন, `nijai/` নামে আরেকটি nested folder-এর মধ্যে নয়। আপনার repository-তে আগে থেকেই README আছে; প্রয়োজনে সেটি নতুন README দিয়ে replace করুন।

## প্রকাশের পর ব্যবহারকারীর একটি কমান্ড

প্রথমে standard native Termux খুলে:

```bash
pkg install -y curl && (set -o pipefail; curl -fsSL https://raw.githubusercontent.com/yeaminuli7/ai/main/bootstrap.sh | bash)
```

ফাইল `main` branch-এ প্রকাশ না করা পর্যন্ত এটি কাজ করবে না। Public না হলে clone করতে authentication লাগবে। কমান্ড প্রথমে curl আনতে পারে, তারপর bootstrap অন্য প্রয়োজনীয় Termux package এবং repository থেকে অ্যাপ আনে; এটি browser login শুরু করার সুযোগ দেয়।

## Git দিয়ে push (ঐচ্ছিক)

Repository-তে ইতিমধ্যে একটি README commit আছে। তাই বিদ্যমান repository clone করে তার ভেতরে এই ফাইলগুলো copy করে commit করুন; আলাদাভাবে `git init` করে push করলে history conflict হতে পারে।

```bash
git clone https://github.com/yeaminuli7/ai.git
cd ai
# এখানে এই প্রকল্পের ফাইলগুলো repository root-এ কপি করুন।
git add .
git commit -m "Add NijAI Termux installer and app"
git push origin main
```

GitHub authentication লাগতে পারে। Token বা OpenRouter credential কখনো repository-তে যোগ করবেন না।

## প্রকাশের আগে

ফোনে fresh Termux দিয়ে installer, browser PKCE login, model list ও অনুমতি-ভিত্তিক tool ব্যবহার পরীক্ষা করুন। Unit tests বাস্তব Android বা security audit-এর বিকল্প নয়। এই installer পরিবর্তনযোগ্য `main` branch থেকে চালায়; কোনো code signature বা checksum নিশ্চিত করা হয় না। নিজের ও ব্যবহারকারীদের নিরাপত্তার জন্য source review এবং পরে pinned release বিবেচনা করুন।
