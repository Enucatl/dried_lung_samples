import h5py
import numpy as np
import click
import matplotlib.pyplot as plt
import os


@click.command()
@click.argument("inputname", type=click.Path(exists=True))
def main(inputname):
    min_x = 350
    min_y = 550
    max_x = 750
    max_y = 1000
    datasets = []
    with h5py.File(inputname, "r") as h5file:
        group = h5file["/entry/data"]
        for dataset in group:
            if group[dataset].shape[0] != 1065:
                return
            new_dataset = group[dataset][min_y:max_y, min_x:max_x]
            datasets.append({"name": dataset, "dataset": new_dataset})
            del group[dataset]
    os.remove(inputname)
    datasets = datasets[:-1]
    with h5py.File(inputname) as h5file:
        group = h5file.require_group("/entry/data")
        for d in datasets:
            group[d["name"]] = d["dataset"]


if __name__ == "__main__":
    main()
