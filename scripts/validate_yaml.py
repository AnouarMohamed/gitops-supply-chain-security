#!/usr/bin/env python3

import pathlib
import sys

try:
    import yaml
except ImportError as exc:
    raise SystemExit("PyYAML is required. Install with: python -m pip install pyyaml") from exc


class UniqueKeyLoader(yaml.SafeLoader):
    pass


def construct_mapping(loader, node, deep=False):
    mapping = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise yaml.constructor.ConstructorError(
                "while constructing a mapping",
                node.start_mark,
                f"found duplicate key: {key}",
                key_node.start_mark,
            )
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


UniqueKeyLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    construct_mapping,
)


def validate_kubernetes_doc(path, index, doc):
    if not isinstance(doc, dict):
        return

    kind = doc.get("kind")
    if not kind:
        return

    required = {
        "Application": ("apiVersion", "metadata", "spec"),
        "Cluster": ("apiVersion", "nodes"),
        "ClusterPolicy": ("apiVersion", "metadata", "spec"),
        "Namespace": ("apiVersion", "metadata"),
        "Pod": ("apiVersion", "metadata", "spec"),
    }

    for field in required.get(kind, ("apiVersion", "metadata")):
        if field not in doc:
            raise ValueError(f"{path}: document {index} ({kind}) missing {field}")

    if kind == "ClusterPolicy":
        rules = doc.get("spec", {}).get("rules")
        if not isinstance(rules, list) or not rules:
            raise ValueError(f"{path}: ClusterPolicy has no spec.rules")


def main(argv):
    if not argv:
        raise SystemExit("usage: validate_yaml.py FILE [FILE...]")

    failed = False
    for raw_path in argv:
        path = pathlib.Path(raw_path)
        try:
            with path.open("r", encoding="utf-8") as handle:
                docs = list(yaml.load_all(handle, Loader=UniqueKeyLoader))
            for index, doc in enumerate(docs, start=1):
                validate_kubernetes_doc(path, index, doc)
            print(f"  ok {path}")
        except Exception as exc:
            failed = True
            print(f"  fail {path}: {exc}", file=sys.stderr)

    if failed:
        raise SystemExit(1)


if __name__ == "__main__":
    main(sys.argv[1:])
