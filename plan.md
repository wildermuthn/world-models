# Plan

Problems:

- Don't understand a lot of the NN, a lot of the math. 
- Takes a long time to train on the non-gpu rendered carracer. 

Good things:

- I understand the general architecture
- I'm able to get OpenGL running in an nvidia-docker if I need to
    - I should write bash script for the original docker, otherwise I might forget?
    - Too late! :D
    - Something like `docker run -it -v /home/wildermuthn/ML/docker/world_models/WorldModelsExperiments:/home/world-models -v /home/wildermuthn/ML/data:/data --runtime=nvidia --env="DISPLAY" --network host --volume="$XAUTH:$XAUTH" world_models_gl:1.2`

Options:
    - Rework python to use a faster render with some other open-ai gym
    - Rework controller to use the VAE+MDRNN imagination
    
    
    
Current Steps:
- Research openai gym, for faster rendering and SOTA benchmarks
    - Use something different than the car-racer? It seems like I could use a smaller car-racing image. Let's try.
- Research how to render OpenGL on the GPU
    - it seems like it is rendering on the gpu anyway. 
    - maybe python is a little slow, maybe it isn't. It is rendering each frame at 6ms or so. That's like 150fps, so it isn't so bad, I suppose.
        so I'm not sure there is any speedup to be had. It does look like if I generate more rollups, then I'll be able to train it better.
    - since it runs multiple works, and the generation of data is cpu-bound, moving the code into CUDA for massive parallelization
        would make the most sense. You could run a shit-ton of simulations then. This is precisely the point of using the imagination, perhaps
        , but perhaps not. I mean, the box2d engine runs at 6ms a frame, which isn't great, but it isn't terrible. But ideally you are running
        a lot of simulations at a time with your evolution strategies, right? 
    - how does the MDNN work? Does it actually use a controller, or does it only predict based on actions from the rollup?
    
    
So what is next? What have you learned?

I learned that it takes way too long to train things! lol.

- Should use cloud GPUs/CPUs
- VAE's aren't that accurate
- Transformers are being used for a lot of things
- NODEs and Normalizing Flows can be very accurate
- Probability density prediction is somewhat at the heart of all this

- I can spend way too much time researching and learning rather than tackling a specific goal that I set for myself.

You have a good VAE. So train it the MDNN. I think I already did train it before. 




So processing power is a problem. That means I need to use Google Cloud, or something like FloydHub.
GCP would be better because it is cheaper and I'll be able to configure it precisely how I want.

However, it is a lot more overhead. It means everything should be in Docker. If it is in docker, then 
at least I can spin up a massively large VM that is suited to what I need. It also means I can run it locally and then deploy it fairly easily. Especially if I use Kubernetes Jobs. A K8 job that just spins up a VM and saves the data (to a persistent drive?) would work far better than having to spin up and down VMs manually, which I always forget to turn off anywway.


GKE might be the best way to do this. The only problem with this is that I can't then use nvidia-docker on my own computer. And unfortunately, GKE might not have display drivers turned on. So the important part here is feature parity. I need to ensure that however it runs on my machine, it is also able to run in the cloud. Even if it uses more GPUs (which I assume is necessary). Also, it looks as if GKE has a very specific driver-set that is loaded into it, CUDA9. I need to have nodepools that distinguish between the different categories.

No, temporary instances of VMs via scripts is a better way to handle this. That way, I ensure that dependencies are correct....

Except that docker is really the best way to ensure the deps are aligned. There's no particular reason I can't have two GPU nodepools that have different versions of CUDA loaded up. My jobs can run on a particular node-pool easily enough.

But is docker worth the hassle, considering display devices and using nvidia-docker? I could just develop remotely, right? No. Well. There are faster download speeds in the cloud, true. And perhaps I could just keep using the shim that outputs display elsewhere. But I did get this fucking graphics card, lol. Why should I waste money?

I need fast feedback loops during development: develop locally
I need to have a 100% consistent environment use nvidia-docker
I need to have environments for different CUDA versions: use multiple clusters or node-pools

It looks like it is already using nvidia-docker?

So let's get this running on GKE

# TO RUN LOCALLY ON NVIDIA-DOCKER

xhost +si:localuser:root

docker run -it --rm \
    --runtime=nvidia \
    -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    tmp
    
    
python traincontroller.py --logdir exp_dir --n-samples 12 --pop-size 36 --target-return 950 --display --max-workers 1
    
// xvfb-run -s "-screen 0 1400x900x24" 

    1  apt-get install vnc4server
    2  apt-get update
    3  apt-get install vnc4server
    4  vnc4server -geometry 1400x1000 -depth 24
    5  export DISPLAY=50d8bb1f1575:1
