# 🕵️ Black Ops LLM Lab

> **Infrastructure as Code for Sovereign & Uncensored AI Deployment.**

This project automatically deploys an ephemeral GPU infrastructure on AWS to run state-of-the-art AI models (DeepSeek R1, Mistral Small 3) in a totally isolated and secure environment.

---

## ⚡ Features

- **100% Ephemeral:** One command to set up the server, one command to destroy everything. Zero dormant costs.
    
- **100% Private:** No ports exposed to the internet. The Web Interface (OpenWebUI) is accessible only via an **Encrypted SSH Tunnel**.
    
- **Tech Stack:**
    
    - **Packer:** Creation of disk images (AMI) with pre-installed Nvidia drivers.
        
    - **Terraform:** Infrastructure provisioning (G4dn.xlarge Instance + Security).
        
    - **Ansible:** Final configuration (Docker + Ollama + OpenWebUI).
        
    - **Docker:** Service isolation.
        

---

## 🛠 Prerequisites

### 1. Local Tools

You must have installed:

- `terraform`
    
- `packer`
    
- `ansible`
    
- `make` (optional but recommended for orchestration)
    
- `aws-cli`
    

### 2. AWS Configuration (Critical!)

Before starting, ensure your AWS account is ready:

1. **Configure CLI:** `aws configure` (with your Access Key / Secret Key).
    
2. **Unlock Quotas (New Account):**
    
    - Go to **Service Quotas** > **Amazon EC2**.
        
    - Request an increase for **"Running On-Demand G instances"**.
        
    - Target value: **8 vCPUs** (required for a `g4dn.xlarge` instance).
        
3. **Enable Billing:**
    
    - If you see an _"InvalidParameterCombination / Free Tier"_ error, your account is restricted.
        
    - Go to **Billing** and click **"Upgrade Plan"** or verify your payment method to authorize paid instances.
        

---

## 🚀 Quick Start

### 1. Build the Image (Build)

Do this once (or if you change regions). This creates a "Golden Image" with Nvidia drivers already installed for fast startup.

```bash
make build
```

_Duration: ~15-20 minutes._

### 2. Deploy Infrastructure (Run)

Launches the server, configures the network, and starts the AI.

```bash
make run
```

_Duration: ~2 minutes._

> **Note:** If you see an `SSH Connection Refused` error at the end, it's normal. The GPU server takes time to start. Wait 1 minute and run `make config` again.

### 3. Connection (The Tunnel)

Once deployment is complete, the terminal will display an SSH command. Run it in a **new terminal** to open the secure tunnel:

```bash
ssh -L 8080:127.0.0.1:8080 -i ansible/private_key.pem ubuntu@<SERVER_IP>
```

Then open your browser at: **[http://localhost:8080](http://localhost:8080)**

### 4. Destruction (Kill Switch)

**Important:** The instance costs about $0.50/hour. Do not leave it running unnecessarily.

```bash
make destroy
```

---

## 🧠 "Black Ops" Model Guide

Your instance (T4 - 16GB VRAM) cannot run everything. Here are the best **Uncensored** (Abliterated) models optimized for this hardware (December 2025).

Since Ollama runs in Docker, use these commands **in your SSH terminal** to download the models:

### 🥇 The Genius (Complex Reasoning)

DeepSeek-R1-Distill-Qwen-32B (Abliterated)

The smartest. Capable of "thinking" (<think>) before answering. Ideal for complex code, logic, and "Red Team" scenarios.

- **VRAM:** ~15.8 GB (Fills GPU to 99%)
    
- **Command:**
    
    ```bash
    sudo docker exec -it ollama ollama run huihui_ai/deepseek-r1-abliterated:32b
    ```
    

### 🏎️ The Speedster (Chat & Writing)

Mistral Small 3 (24B - Abliterated)

Best speed/intelligence ratio. More creative and "human" than Qwen models.

- **VRAM:** ~14.0 GB
    
- **Command:**
    
    ```bash
    sudo docker exec -it ollama ollama run huihui_ai/mistral-small-abliterated
    ```
    

### 🎯 The Precision (Pure Logic)

Phi-4 (14B - Abliterated)

Very dense model from Microsoft. Excellent for math and strict adherence to formats (JSON, SQL).

- **VRAM:** ~10 GB (Very light)
    
- **Command:**
    
    ```bash
    sudo docker exec -it ollama ollama run huihui_ai/phi4-abliterated
    ```
    

---

## 🔧 Troubleshooting

**Problem: "Model requires more system memory"**

- **Cause:** You tried to load a model that is too large, or an old model remained loaded in memory ("Zombie").
    
- **Solution:** Force restart the AI engine to clear VRAM.
    
    ```bash
    sudo docker restart ollama
    ```
    

**Problem: "InvalidParameterCombination" during `make run`**

- **Cause:** AWS considers your account as "Free Tier only".
    
- **Solution:** Check your payment info in the AWS console or enable "Spot" mode in `terraform/aws/main.tf` to bypass the restriction.
    

**Problem: "Ollama command not found"**

- **Cause:** You are typing the command on the host server, but Ollama is in Docker.
    
- **Solution:** Always prefix with `sudo docker exec -it ollama...`.