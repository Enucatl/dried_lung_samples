import click
import h5py
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt


@click.command()
@click.argument("filename", type=click.Path(exists=True))
def main(filename):
    # dataset = h5py.File(filename)["postprocessing/visibility"]
    dataset = h5py.File(filename)["postprocessing/dpc_reconstruction"][
        ..., 0]
    fig, ax = plt.subplots()
    # limits = [0.7, 1]
    limits = stats.mstats.mquantiles(dataset, prob=[0.1, 0.9])
    print(limits)
    image = ax.imshow(dataset, interpolation="none", aspect='auto')
    image.set_clim(*limits)
    plt.ion()
    plt.show()
    input()

if __name__ == "__main__":
    main()
