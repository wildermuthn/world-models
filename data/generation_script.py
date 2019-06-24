"""
Encapsulate generate data to make it parallel
"""
from os import makedirs
from os.path import join
import argparse
from multiprocessing import Pool
from subprocess import call

def _threaded_generation(i):
    tdir = join(args.rootdir, 'thread_{}'.format(i))
    makedirs(tdir, exist_ok=True)
    cmd = ["python", "-m", "data.carracing", "--dir",
            tdir, "--rollouts", str(rpt), "--policy", args.policy]
    cmd = " ".join(cmd)
    print(cmd)
    call(cmd, shell=True)
    return True

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--rollouts', type=int, help="Total number of rollouts.", default=2)
    parser.add_argument('--threads', type=int, help="Number of threads", default=7)
    parser.add_argument('--rootdir', type=str, help="Directory to store rollout "
                                                    "directories of each thread", default="datasets/carracing3")
    parser.add_argument('--policy', type=str, choices=['brown', 'white'],
                        help="Directory to store rollout directories of each thread",
                        default='brown')
    args = parser.parse_args()

    rpt = args.rollouts

    with Pool(args.threads) as p:
        p.map(_threaded_generation, range(args.threads))
