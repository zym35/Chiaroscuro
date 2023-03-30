using UnityEngine;
using UnityEditor;
using System;

public class RoomGenerator : MonoBehaviour
{
    [SerializeField] private int numberOfRooms = 5;
    [SerializeField] private float roomWidth = 10f;
    [SerializeField] private float roomHeight = 5f;

    private GameObject[] rooms;
    private GameObject[] corridors;

    private void Start()
    {
        GenerateRooms();
        GenerateCorridors();
    }

    private void GenerateRooms()
    {
        rooms = new GameObject[numberOfRooms];

        for (int i = 0; i < numberOfRooms; i++)
        {
            // Create a new game object to hold the room mesh and collider
            GameObject room = new GameObject("Room " + i);
            MeshFilter meshFilter = room.AddComponent<MeshFilter>();
            MeshRenderer meshRenderer = room.AddComponent<MeshRenderer>();
            BoxCollider boxCollider = room.AddComponent<BoxCollider>();

            // Generate the room mesh
            Mesh mesh = new Mesh();
            mesh.vertices = new Vector3[]
            {
                new Vector3(-roomWidth / 2f, 0f, -roomWidth / 2f),
                new Vector3(-roomWidth / 2f, 0f, roomWidth / 2f),
                new Vector3(roomWidth / 2f, 0f, roomWidth / 2f),
                new Vector3(roomWidth / 2f, 0f, -roomWidth / 2f),
                new Vector3(-roomWidth / 2f, roomHeight, -roomWidth / 2f),
                new Vector3(-roomWidth / 2f, roomHeight, roomWidth / 2f),
                new Vector3(roomWidth / 2f, roomHeight, roomWidth / 2f),
                new Vector3(roomWidth / 2f, roomHeight, -roomWidth / 2f)
            };
            mesh.triangles = new int[]
            {
                0, 1, 4,
                4, 1, 5,
                1, 2, 5,
                5, 2, 6,
                2, 3, 6,
                6, 3, 7,
                3, 0, 7,
                7, 0, 4,
                4, 5, 6,
                6, 7, 4,
                0, 3, 2,
                2, 1, 0
            };
            mesh.RecalculateNormals();

            // Assign the mesh to the mesh filter and renderer
            meshFilter.mesh = mesh;
            meshRenderer.material = new Material(Shader.Find("Standard"));

            // Position the room in the scene
            room.transform.position = new Vector3(i * roomWidth, 0f, 0f);

            // Add the room to the rooms array
            Array.Resize(ref rooms, rooms.Length + 1);
            rooms[rooms.Length - 1] = room;
        }
    }

    private void GenerateCorridors()
    {
        corridors = new GameObject[numberOfRooms - 1];

        for (int i = 1; i < numberOfRooms; i++)
        {
            // Create a new game object to hold the corridor mesh and collider
            GameObject corridor = new GameObject("Corridor " + i);
            MeshFilter meshFilter = corridor.AddComponent<MeshFilter>();
            MeshRenderer meshRenderer = corridor.AddComponent<MeshRenderer>();
            BoxCollider boxCollider = corridor.AddComponent<BoxCollider>();

            // Generate the corridor mesh
            Mesh mesh = new Mesh();
            Vector3[] vertices = new Vector3[4];
            vertices[0] = new Vector3(0f, 0f, 0f);
            vertices[1] = new Vector3(roomWidth, 0f, 0f);
            vertices[2] = new Vector3(roomWidth, 0f, -roomWidth);
            vertices[3] = new Vector3(2f * roomWidth, 0f, -roomWidth);
            mesh.vertices = vertices;
            mesh.triangles = new int[] { 0, 1, 2, 2, 1, 3 };
            mesh.RecalculateNormals();

            // Assign the mesh to the mesh filter and renderer
            meshFilter.mesh = mesh;
            meshRenderer.material = new Material(Shader.Find("Standard"));

            // Position the corridor in the scene
            corridor.transform.position = new Vector3((i - 1) * roomWidth, 0f, 0f);

            // Rotate the corridor to connect the rooms
            Vector3 direction = rooms[i].transform.position - rooms[i - 1].transform.position;
            corridor.transform.rotation = Quaternion.LookRotation(direction);

            // Add the corridor to the corridors array
            Array.Resize(ref corridors, corridors.Length + 1);
            corridors[corridors.Length - 1] = corridor;
        }
    }
}