# -*- coding: utf-8 -*-

"""Console script for pya."""
import sys
import click


@click.command()
@click.argument('package')
def main(package, args=None):
    """Console script for pya."""
    click.echo("Python Application Installer")
    from subprocess import Popen, PIPE, STDOUT

    p = Popen(['pip', 'install', '--help'], stdout = PIPE, stderr = STDOUT)
    for line in p.stdout:
        print(line.decode('utf-8').replace('\n', ''))
    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
