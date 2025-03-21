import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway(5000, {
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private users: { userId: string; socketId: string }[] = [];

  private addUser(userId: string, socketId: string): void {
    if (!this.users.some((user) => user.userId === userId)) {
      this.users.push({ userId, socketId });
    }
  }

  private removeUser(socketId: string): void {
    this.users = this.users.filter((user) => user.socketId !== socketId);
  }

  private getUser(
    userId: string,
  ): { userId: string; socketId: string } | undefined {
    return this.users.find((user) => user.userId === userId);
  }

  handleConnection(client: Socket): void {
    console.log('A user connected:', client.id);
  }

  handleDisconnect(client: Socket): void {
    console.log('A user disconnected:', client.id);
    this.removeUser(client.id);
    this.server.emit('getUsers', this.users);
  }

  @SubscribeMessage('addUser')
  handleAddUser(client: Socket, userId: string): void {
    console.log(userId);
    this.addUser(userId, client.id);
    this.server.emit('getUsers', this.users);
  }

  @SubscribeMessage('sendMessage')
  handleSendMessage(
    client: Socket,
    payload: { senderId: string; receiverId: string; text: string },
  ): void {
    const { senderId, receiverId, text } = payload;
    console.log(payload);
    const user = this.getUser(receiverId);
    if (user) {
      this.server
        .to(user.socketId)
        .emit('getMessage', { senderId, text, receiverId });
    }
  }
}
